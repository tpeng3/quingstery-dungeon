extends Control

var current_page = 1
var max_pages = 1
var ListItem = load("res://prefabs/UI/ItemMenu/ListItem.tscn")
@export var focused_item:ListItem = null

enum CostType {
	NONE,
	BUY,
	SELL
}
@export var cost_type:CostType = CostType.NONE

@onready var ItemContainer = $OuterPadding/SplitContainer/LeftPanel/PanelPadding/FlowContainer
@onready var PaginationLabel = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/PaginationLabel
@onready var ArrowBack = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/ArrowBack/ArrowBtn
@onready var ArrowNext = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/ArrowNext/ArrowBtn

signal menu_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	# instantiate items from the inventory
	for child in ItemContainer.get_children():
		child.queue_free()
	var items = Inventory.print_items()
	for i in items:
		var dict_item = Inventory.find_item(i.name)
		var node = ListItem.instantiate()
		node.set("item_name", i.name)
		node.set("item_amount", i.count)
		match cost_type:
			CostType.BUY:
				node.set("item_cost", dict_item.buy)
			CostType.SELL:
				node.set("item_cost", dict_item.sell)
		node.on_focus.connect(_update_right_panel)
		ItemContainer.add_child(node)
		
	max_pages = max(ceil(Inventory.print_items().size() / 8), 1)
	_show_page()
	hide()
	
func show_menu():
	current_page = 1
	_show_page()
	show()
	if Inventory.get_inv_count() < 1:
		ItemContainer.hide()
		$OuterPadding/SplitContainer/RightPanel.hide()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.show()
		$OuterPadding/SplitContainer/LeftPanel/FooterMargin/NaviClose.grab_focus()
	else:
		ItemContainer.show()
		$OuterPadding/SplitContainer/RightPanel.show()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.hide()
		ItemContainer.get_child(0).grab_focus()

# update after a listitem is removed from the page after sell or use
func _update_page():
	_show_page()
	if Inventory.get_inv_count() < 1:
		ItemContainer.hide()
		$OuterPadding/SplitContainer/RightPanel.hide()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.show()
		$OuterPadding/SplitContainer/LeftPanel/FooterMargin/NaviClose.grab_focus()
	else:
		ItemContainer.show()
		$OuterPadding/SplitContainer/RightPanel.show()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.hide()
		ItemContainer.get_child(0).grab_focus()

func _show_page(page=current_page):
	_update_page_text()
	var visible_items = ItemContainer.get_children().slice((page - 1) * 8, page * 8)
	for n in ItemContainer.get_children():
		n.visible = n in visible_items

func _on_prev_pressed():
	if current_page > 1:
		current_page -= 1
		_show_page()

func _on_next_pressed():
	if current_page < max_pages:
		current_page += 1
		_show_page()

func _on_navi_close_pressed():
	hide()
	emit_signal("menu_closed")

func _update_page_text():
	PaginationLabel.text = "Page 0" + str(current_page) + "/0" + str(max_pages)
	ArrowBack.disabled = current_page <= 1
	ArrowNext.disabled = current_page >= max_pages

func _update_right_panel(node):
	focused_item = node
	var item_dict = Inventory.find_item(node.item_name)
	var item_texture = load(item_dict.path)
	$OuterPadding/SplitContainer/RightPanel/SpriteCentering/ItemSprite.texture = item_texture
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/TitleMargin/ItemName.text = node.item_name.to_upper()
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/ItemDesc.text = item_dict.description
	$AnimationPlayer.play("bump")


func _on_button_right_focus_entered():
	focused_item.find_child("Panel").theme_type_variation = "Panel_Highlight_Alt"
	var path = $OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.get_path_to(focused_item)
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.focus_neighbor_left = path

func _on_button_right_focus_exited():
	focused_item.find_child("Panel").theme_type_variation = ""

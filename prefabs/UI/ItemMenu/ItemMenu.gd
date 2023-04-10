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
var item_list = Inventory.print_items()
var DimColor = Color(0.87, 0.78, 0.83, 0.9)

signal menu_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_item_list(item_list)
	_show_page()
	hide()

func refresh_item_list(new_item_list):
	item_list = new_item_list
	for child in ItemContainer.get_children():
		child.get_parent().remove_child(child)
		child.queue_free()
	for i in item_list:
		var dict_item = Inventory.find_item(i.name)
		var node = ListItem.instantiate()
		node.set("item_name", i.name)
		node.set("item_amount", i.count)
		match cost_type:
			CostType.SELL:
				node.set("item_cost", dict_item.sell)
		node.on_focus.connect(_update_right_panel)
		node.gui_input.connect(_on_item_gui_input)
		ItemContainer.add_child(node)
		node.add_to_group("LeftButtons")
		
	max_pages = max(ceil(item_list.size() / 8.0), 1)
	
	
func show_menu():
	current_page = 1
	_show_page()
	show()
	_update_panel_focus_color()
	if item_list.size() < 1:
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
	var new_max_page = max(ceil((Inventory.print_items().size()) / 8.0), 1)
	if current_page > 1 and new_max_page < max_pages:
		current_page -= 1
		max_pages = new_max_page
	_show_page()
	if item_list.size() < 1:
		ItemContainer.hide()
		$OuterPadding/SplitContainer/RightPanel.hide()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.show()
		$OuterPadding/SplitContainer/LeftPanel/FooterMargin/NaviClose.grab_focus()
	else:
		ItemContainer.show()
		$OuterPadding/SplitContainer/RightPanel.show()
		$OuterPadding/SplitContainer/LeftPanel/PanelPadding/NoItemsText.hide()
		ItemContainer.get_child((current_page-1) * 8).grab_focus()

func _show_page():
	_update_page_text()
	var visible_items = ItemContainer.get_children().slice((current_page - 1) * 8, current_page * 8)
	visible_items[0].grab_focus()
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
	var page_num = "0" + str(current_page) if current_page < 10 else str(current_page)
	var max_page_num = "0" + str(max_pages) if max_pages < 10 else str(max_pages)
	PaginationLabel.text = "Page " + page_num + "/" + max_page_num
	ArrowBack.disabled = current_page <= 1
	ArrowNext.disabled = current_page >= max_pages

func _on_item_gui_input(event):
	if event.is_action_pressed("ui_left"):
		_on_prev_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_next_pressed()
	elif event.is_action_pressed("ui_accept"):
#		_update_panel_focus_color(true)
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.grab_focus()
#		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		$OuterPadding/SplitContainer/LeftPanel/FooterMargin/NaviClose.grab_focus()

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

func _update_panel_focus_color(isRight = false):
	$OuterPadding/SplitContainer/LeftPanel.modulate = DimColor if isRight else Color(1, 1, 1, 1)
	$OuterPadding/SplitContainer/RightPanel.modulate = DimColor if !isRight else Color(1, 1, 1, 1)
	for node in get_tree().get_nodes_in_group("LeftButtons"):
		node.focus_mode = FOCUS_NONE if isRight else FOCUS_ALL
		print(node.name, node.focus_mode)
	for node in get_tree().get_nodes_in_group("RightButtons"):
		node.focus_mode = FOCUS_NONE if !isRight else FOCUS_ALL
		print(node.name, node.focus_mode)
		
	

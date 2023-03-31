extends Control

var current_page = 1
var max_pages = 1
var ListItem = load("res://prefabs/UI/ItemMenu/ListItem.tscn")

@export var sellMode:bool = false

@onready var ItemContainer = $OuterPadding/SplitContainer/LeftPanel/PanelPadding/FlowContainer
@onready var PaginationLabel = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/PaginationLabel
@onready var ArrowBack = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/ArrowBack/ArrowBtn
@onready var ArrowNext = $OuterPadding/SplitContainer/LeftPanel/Pagination/BoxContainer/ArrowNext/ArrowBtn

signal menu_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	_show_page()
	max_pages = ceil(Inventory.print_items().size() / 8)
	print(max_pages)
	_update_page_text()
	$OuterPadding/SplitContainer/LeftPanel/FooterMargin/NaviClose.grab_focus()

func _show_page(page=0):
	var items = Inventory.print_items().slice(page * 8, (page * 8) + 8)
	for n in items.size() - 1:
		print(n)
		var dict_item = Inventory.find_item(items[n].name)
		var node = ListItem.instantiate()
		node.set("item_name", items[n].name)
		node.set("item_info", dict_item.sell if dict_item.sell > 0 else "Not for Sale")
		ItemContainer.add_child(node)

func _on_prev_pressed():
	if current_page > 1:
		_show_page(current_page - 1)
		current_page -= 1
		ArrowBack.disabled = false
		if current_page == 1:
			ArrowBack.disabled = true
	else:
		ArrowBack.disabled = true
	_update_page_text()

func _on_next_pressed():
	if current_page < max_pages:
		_show_page(current_page + 1)
		current_page += 1
		ArrowBack.disabled = false
		if current_page == max_pages:
			ArrowBack.disabled = true
	else:
		ArrowBack.disabled = true
	_update_page_text()

func _on_navi_close_pressed():
	hide()
	emit_signal("menu_closed")

func _update_page_text():
	PaginationLabel.text = "Page 0" + str(max(current_page, 1)) + "/0" + str(max(max_pages, 1))

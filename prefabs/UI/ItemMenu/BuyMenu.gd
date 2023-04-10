extends "res://prefabs/UI/ItemMenu/ItemMenu.gd"

@export var shop_node:Node
@onready var ReqList = $OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/RequirementsList

signal on_buy(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	$ClosePopup.on_close.connect(_on_popup_close)
	
func init_shop():
	# clear item list
	for child in ItemContainer.get_children():
		child.queue_free()
	item_list = shop_node.shop_items
	for i in item_list:
		var dict_item = Inventory.find_item(i.item)
		var node = ListItem.instantiate()
		node.set("item_name", i.item)
		node.set("item_type", i.type)
		if "trade" in i and i.trade.size() > 0:
			node.set("item_trade", i.trade)
		else:
			node.set("item_cost", i.cost)
		
		node.on_focus.connect(_update_right_panel)
		node.gui_input.connect(_on_item_gui_input)
		ItemContainer.add_child(node)
		node.add_to_group("LeftButtons")
	
	max_pages = max(ceil(item_list.size() / 8.0), 1)
	_show_page()
	hide()

func _update_right_panel(node):
	super(node)
	var inv_count = Inventory.inventory[node.item_name].count if node.item_name in Inventory.inventory else 0
	var storage_count = Inventory.storage[node.item_name].count if node.item_name in Inventory.storage else 0
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/ItemDesc.text += \
		" (Owned: " + str(inv_count + storage_count) + ")"
	
	ReqList.hide()
	if (node.item_type == "Equip" or node.item_type == "Upgrade") and node.item_name in Inventory.inventory:
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "sold out"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.disabled = true
	elif node.item_trade:
		ReqList.show()
		for n in 3:
			var ReqItem = ReqList.get_child(n)
			if n < node.item_trade.size():
				ReqItem.show_req(node.item_trade[n])
			else:
				ReqItem.hide()
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "trade"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.disabled = !_can_trade(node)
	elif Inventory.gald < node.item_cost:
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "not enough gald"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.disabled = true
	else:
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "buy"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.disabled = false		

func _on_popup_close():
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.grab_focus()

func _on_buy():
	var overflow = false
	if focused_item.item_trade:
		for i in focused_item.item_trade:
			Inventory.remove_item(i.item, i.amount)
		Inventory.add_item(focused_item.item_name)
	else:
		if Inventory.get_inv_count() >= Inventory.max and Inventory.get_inv_count(true) >= Inventory.STORAGE_MAX:
			$ClosePopup.show_popup("Both your inventory and storage is full! Please clear it out before purchasing.")
			return
		else:
			Inventory.gald -= focused_item.item_cost
			overflow = Inventory.add_item(focused_item.item_name)
	focused_item.update_item()
	on_buy.emit(focused_item)
	_update_right_panel(focused_item)
	if overflow:
		$ClosePopup.show_popup("Your inventory is full so purchased items have been delivered to your storage at [b]Town Hall[/b].")

func _can_trade(node):
	var can_trade = true
	for i in node.item_trade:
		var inv_count = Inventory.inventory[i.item].count if i.item in Inventory.inventory else 0
		var storage_count = Inventory.storage[i.item].count if i.item in Inventory.storage else 0
		if (inv_count + storage_count < i.amount):
			return false
	return true

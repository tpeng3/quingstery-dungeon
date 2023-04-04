extends "res://prefabs/UI/ItemMenu/ItemMenu.gd"

@export var show_storage = false

func _ready():
	$ClosePopup.on_close.connect(_on_close_popup)
	item_list = Inventory.print_items(show_storage)
	super()
	if show_storage:
		$OuterPadding/SplitContainer/LeftPanel/TitleMargin/LeftTitle.text = "Take Items"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "take"
		$AmountPopup.popup_type = $AmountPopup.PopupType.TAKE
		$AmountPopup.item_desc = "How many [b][item][/b] do you want to take from storage?"
	else:
		$OuterPadding/SplitContainer/LeftPanel/TitleMargin/LeftTitle.text = "Store Items"
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.text = "store"
		$AmountPopup.popup_type = $AmountPopup.PopupType.STORE
		$AmountPopup.item_desc = "How many [b][item][/b] do you want to move to storage?"

func show_menu():
	refresh_item_list(Inventory.print_items(show_storage))
	super()

func _on_store_pressed():
	if focused_item.item_amount > 1:
		$AmountPopup.show_popup(focused_item)
		$AmountPopup/SplitContainer/PopupBox/SplitContainer/AmountSelect/SplitContainer/MiddleRow/Left.grab_focus()
		$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.connect(_on_back)
		$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.connect(_on_store)
	else:
		if show_storage and Inventory.get_inv_count() + 1 > Inventory.max:
			$ClosePopup.show_popup("Sorry, your inventory is full.")
			return
		elif Inventory.get_inv_count(true)  + 1 > Inventory.STORAGE_MAX:
			$ClosePopup.show_popup("Sorry, your storage is full. (Max: 99)")
			return
		Inventory.add_item(focused_item.item_name, 1, !show_storage)
		Inventory.remove_item(focused_item.item_name, 1, show_storage)
		focused_item.get_parent().remove_child(focused_item)
		focused_item.queue_free()
		_update_page()

func _on_back():
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(_on_store)
	$AmountPopup.hide()
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.grab_focus()

func _on_store():
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(_on_store)
	$AmountPopup.hide()
	var amount = $AmountPopup/SplitContainer/PopupBox/SplitContainer/AmountSelect.amount
	if show_storage and Inventory.get_inv_count() + amount > Inventory.max:
		$ClosePopup.show_popup("Sorry, you don't have enough space for these.")
		return
	elif Inventory.get_inv_count(true) > Inventory.STORAGE_MAX:
		$ClosePopup.show_popup("Sorry, your storage is full.")
		return
	Inventory.add_item(focused_item.item_name, amount, !show_storage)
	Inventory.remove_item(focused_item.item_name, amount, show_storage)
	focused_item.item_amount -= amount
	focused_item.update_item()
	if (focused_item.item_amount <= 0):
		focused_item.get_parent().remove_child(focused_item)
		focused_item.queue_free()
		_update_page()
	else:
		focused_item.grab_focus()

func _on_close_popup():
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.grab_focus()

func _update_right_panel(node):
	super(node)
	if show_storage:
		var count = Inventory.inventory[node.item_name].count if node.item_name in Inventory.inventory else 0
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/ItemDesc.text += \
			" (Inventory: " + str(count) + ")"
	else:
		var count = Inventory.storage[node.item_name].count if node.item_name in Inventory.storage else 0
		$OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/ItemDesc.text += \
			" (Storage: " + str(count) + ")"

extends "res://prefabs/UI/ItemMenu/ItemMenu.gd"

func _on_sell_pressed():
	if focused_item.item_cost < 0:
		return
	elif focused_item.item_amount > 1:
		$AmountPopup.show_popup(focused_item)
		$AmountPopup/SplitContainer/PopupBox/SplitContainer/AmountSelect/SplitContainer/MiddleRow/Left.grab_focus()
		$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.connect(_on_back)
		$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.connect(_on_sell)
	else:
		Inventory.gald += focused_item.item_cost
		Inventory.remove_item(focused_item.item_name)
		focused_item.get_parent().remove_child(focused_item)
		focused_item.queue_free()
		show_menu()

func _on_back():
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(_on_sell)
	$AmountPopup.hide()
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/FooterMargin/ButtonRight.grab_focus()

func _on_sell():
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(_on_sell)
	$AmountPopup.hide()
	var amount = $AmountPopup/SplitContainer/PopupBox/SplitContainer/AmountSelect.amount
	Inventory.gald += focused_item.item_cost * amount
	Inventory.remove_item(focused_item.item_name, amount)
	focused_item.item_amount -= amount
	focused_item.update_item()
	if (focused_item.item_amount <= 0):
		focused_item.get_parent().remove_child(focused_item)
		focused_item.queue_free()
		show_menu()
	else:
		focused_item.grab_focus()

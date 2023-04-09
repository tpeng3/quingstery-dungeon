extends "res://prefabs/Dialogue/DialogueBox/DialogueBox.gd"

signal on_trade

func show_trade_popup(request, request_max, reward, reward_num):
	$AmountPopup.show_trade_popup(request, request_max, reward, reward_num)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.connect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.connect(_on_trade)

func show_close_popup(text):
	$ClosePopup.show_popup(text)

func _on_back():
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_on_back)
	$AmountPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(_on_trade)
	_on_dialogue_finished()
	$AmountPopup.hide()
	
func _on_trade():
	on_trade.emit($AmountPopup/SplitContainer/PopupBox/SplitContainer/AmountSelect.amount)

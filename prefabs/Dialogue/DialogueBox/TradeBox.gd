extends "res://prefabs/Dialogue/DialogueBox/DialogueBox.gd"

func _on_dialogue_yes_pressed():
#	$ButtonClick.play()
	DialogueSelect.hide()
	emit_signal("yes_selected")

func show_trade_popup(request, request_max, reward, reward_num):
	$AmountPopup.show_trade_popup(request, request_max, reward, reward_num)

func show_close_popup(text):
	$ClosePopup.show_popup(text)

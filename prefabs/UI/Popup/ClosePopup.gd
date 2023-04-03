extends Control

signal on_close

func show_popup(text):
	$SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = text
	show()
	$SplitContainer/PopupBox/FooterMargin/ButtonMid.grab_focus()

func _on_close_pressed():
	hide()
	on_close.emit()

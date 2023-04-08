extends MarginContainer

@export var amount:int = 0
@export var amount_max:int = 2
var amount_focused = false

signal amount_update(amount)

func update_arrows():
	$SplitContainer/MiddleRow/NumberDisplay.text = str(amount)
	$SplitContainer/MiddleRow/NumberDisplay/Left.disabled = amount <= 0
	$SplitContainer/MiddleRow/NumberDisplay/Right.disabled = amount >= amount_max
	amount_update.emit(amount)

func _on_number_display_focus_entered():
	$SplitContainer/MiddleRow/NumberDisplay.theme_type_variation = "Label_Active"

func _on_number_display_focus_exited():
	$SplitContainer/MiddleRow/NumberDisplay.theme_type_variation = "Label"

func _on_number_display_gui_input(event):
	if event.is_action_pressed("ui_left"):
		amount = max(0, amount - 1)
		update_arrows()	
	elif event.is_action_pressed("ui_right"):
		amount = min(amount + 1, amount_max)
		update_arrows()

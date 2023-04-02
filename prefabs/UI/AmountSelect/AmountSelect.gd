extends MarginContainer

@export var amount:int = 0
@export var amount_max:int = 2

signal amount_update(amount)

func _on_left_pressed():
	amount = max(0, amount - 1)
	update_arrows()
	
func _on_right_pressed():
	amount = min(amount + 1, amount_max)
	update_arrows()

func update_arrows():
	$SplitContainer/MiddleRow/NumberDisplay.text = str(amount)
	$SplitContainer/MiddleRow/Left.disabled = amount <= 0
	$SplitContainer/MiddleRow/Right.disabled = amount >= amount_max
	amount_update.emit(amount)

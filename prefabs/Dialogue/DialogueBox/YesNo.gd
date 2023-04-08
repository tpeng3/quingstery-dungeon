extends MarginContainer

func show_yesno():
	show()
	$DialogueSelect/DialogueYes.grab_focus()
	print("hello check?")

func _on_dialogue_yes_focus_entered():
	$Arrow.rotation_degrees = 0
	$DialogueSelect/DialogueYes.scale = Vector2(1.5, 1.5)
	$DialogueSelect/DialogueNo.scale = Vector2(1.0, 1.0)

func _on_dialogue_no_focus_entered():
	$Arrow.rotation_degrees = -90
	$DialogueSelect/DialogueYes.scale = Vector2(1.0, 1.0)
	$DialogueSelect/DialogueNo.scale = Vector2(1.5, 1.5)

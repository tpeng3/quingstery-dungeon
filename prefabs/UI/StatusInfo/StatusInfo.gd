extends CanvasLayer

func _ready():
	$MenuWindows.hide()

func _input(event):
	if event.is_action_pressed("game_menu"):
		if not $MenuWindows.visible:
			$MenuButtons/VBoxContainer/AnimationPlayer.play("EaseIn")
			_on_status_pressed()
			$MenuWindows.visible = true
			Global.freezeQuingee = true
		else:
			_on_exit_pressed()

func _on_status_pressed():
	$MenuButtons/VBoxContainer/StatusBtn/Status.grab_focus()
	pass # Replace with function body.

func _on_inventory_pressed():
	pass # Replace with function body.

func _on_quest_pressed():
	pass # Replace with function body.

func _on_exit_pressed():
	$MenuButtons/VBoxContainer/AnimationPlayer.play_backwards("EaseIn")
	await $MenuButtons/VBoxContainer/AnimationPlayer.animation_finished
	$MenuWindows.visible = false
	Global.freezeQuingee = false
	if $MenuButtons/VBoxContainer/StatusBtn/Status.has_focus():
		$MenuButtons/VBoxContainer/StatusBtn/Status.release_focus()

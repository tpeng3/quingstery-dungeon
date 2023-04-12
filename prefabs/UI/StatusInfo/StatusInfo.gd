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
	$MenuWindows/StatusMenu.show_screen()
	$MenuWindows/InventoryMenu.hide()
	$MenuWindows/QuestsMenu.hide()

func _on_inventory_pressed():
	$MenuWindows/StatusMenu.hide()
	$MenuWindows/InventoryMenu.show_menu()
	$MenuWindows/QuestsMenu.hide()

func _on_quest_pressed():
	$MenuWindows/StatusMenu.hide()
	$MenuWindows/InventoryMenu.hide()
	$MenuWindows/QuestsMenu.show()

func _on_exit_pressed():
	$MenuWindows/StatusMenu.hide()
	$MenuWindows/InventoryMenu.hide()
	$MenuWindows/QuestsMenu.hide()
	$MenuButtons/VBoxContainer/AnimationPlayer.play_backwards("EaseIn")
	$MenuWindows.visible = false
	await $MenuButtons/VBoxContainer/AnimationPlayer.animation_finished
	Global.freezeQuingee = false
	if $MenuButtons/VBoxContainer/StatusBtn/Status.has_focus():
		$MenuButtons/VBoxContainer/StatusBtn/Status.release_focus()

extends Control

const SCALE = 5
const DURATION = .2

@onready var Camera = get_parent().get_parent()

func _on_focus_entered():
	$AnimationPlayer.play("scale")
	Camera.focused_location = self

func _on_focus_exited():
	$AnimationPlayer.play_backwards("scale")

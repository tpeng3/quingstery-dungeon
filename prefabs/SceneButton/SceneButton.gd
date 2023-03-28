extends Button

@export var scene: String

signal on_focus
signal on_exit

func _ready() -> void:
	pass

func _on_pressed():
	if scene:
		SceneManager.change_scene(scene)

func _on_focus_entered():
	on_focus.emit(self)

func _on_focus_exited():
	on_exit.emit(self)

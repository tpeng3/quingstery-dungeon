extends Button

@export var scene: String

func _ready() -> void:
	pass

func _on_button_button_up():
	if scene:
		SceneManager.change_scene(scene)
	else:
		print("TODO: screen hasn't been set yet")

func _on_reset_button_up():
	SceneManager.reset_scene_manager()

func _on_loading_scene_button_up():
	SceneManager.set_recorded_scene(scene)
	SceneManager.change_scene("loading")

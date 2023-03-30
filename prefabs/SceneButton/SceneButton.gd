extends Button

@export var scene: String
@export var npc: Dictionary

signal on_focus
signal on_exit
signal on_dialogue

func _ready() -> void:
	pass

func _on_pressed():
	if scene:
		SceneManager.change_scene(scene)
	elif npc:
		on_dialogue.emit(self)

func _on_focus_entered():
	on_focus.emit(self)

func _on_focus_exited():
	on_exit.emit(self)

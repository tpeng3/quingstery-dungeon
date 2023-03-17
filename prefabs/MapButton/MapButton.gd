extends Control

var bip:Texture2D = load("res://assets/ui/mapbip.png")
@export var preview:Texture2D
@export var skipPreview:bool = false
@export var mapDesc:String
@onready var Camera = get_parent().get_parent().get_node("Camera2D")

signal map_focused

func _on_focus_entered():
	if not skipPreview:
		$TextureButton.texture_normal = preview
		$AnimationPlayer.play("scale")
	Camera.focused_location = self
	z_index = 1
	emit_signal("map_focused", self)

func _on_focus_exited():
	if not skipPreview:
		$AnimationPlayer.play_backwards("scale")
		await $AnimationPlayer.animation_finished
		$TextureButton.texture_normal = bip
	self.scale = Vector2(1, 1)
	z_index = 0

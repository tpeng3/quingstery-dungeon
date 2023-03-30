extends Control

var bip:Texture2D = load("res://assets/ui/mapbip.png")

@export var scene:String 
@export var preview:Texture2D
@export_multiline var mapDesc:String
@onready var Camera = get_parent().get_parent().get_node("Camera2D")

signal map_focused

func enter_focus():
	$Sprite.texture = preview
	$AnimationPlayer.play("scale")
	Camera.focused_location = self
	z_index = 1
	emit_signal("map_focused", self)

func exit_focus():
	$AnimationPlayer.play_backwards("scale")
	await $AnimationPlayer.animation_finished
	$Sprite.texture = bip
	self.scale = Vector2(1, 1)
	z_index = 0

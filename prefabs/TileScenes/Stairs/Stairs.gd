extends Area2D

var entered_stairs = false
@onready var Idle = preload("res://assets/tile/Stair_Tile_2.png")
@onready var Highlight = preload("res://assets/tile/Stair_Tile1.png")

signal on_stairs
signal find_stairs

func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	if (event.is_action_released("ui_accept")) and entered_stairs:
		find_stairs.emit()

func _on_body_entered(body):
	if body.name == "Quingee":
		entered_stairs = true
		$Sprite.texture = Highlight

func _on_body_exited(body):
	entered_stairs = false
	$Sprite.texture = Idle

extends Area2D

enum ActionState { 
	IDLE,
	COMPLETE
}
var state = ActionState.IDLE
var rewards = []
var rng = RandomNumberGenerator.new()

@onready var Idle = preload("res://assets/tile/Forage_Rock_Sprite2.png")
@onready var Highlight = preload("res://assets/tile/Forage_Rock_Sprite1.png")

signal item_get

func _ready():
	var location = "Throat" # TODO: make enum or typecheck
	rewards = Inventory.get_items_json().filter(
		func(i): return i.source == location and i.category == "Mining"
	)

func _input(event):
	# ignore input when quingee is frozen
	if $"/root/Global".freezeQuingee or state == ActionState.COMPLETE:
		return

	# on enter/space or mouse click
	if event.is_action_pressed("ui_accept") and has_overlapping_bodies():
		$Icon.visible = false
		$Icon/AnimationPlayer.pause()
		$Control.visible = true
		# TODO: add mining values and difficulty
		# TODO: reduce hunger when mining
		$Control/ProgressBar.value += 1
		$"/root/Global".currentHunger -= 0.5
		if $Control/ProgressBar.value >= $Control/ProgressBar.max_value:
			_on_mining_complete()

func _on_mining_complete():
	state = ActionState.COMPLETE
	$Sprite/Sparkle.visible = false
	$Control.visible = false
	$Sprite.texture = Idle
	rng.randomize()
	var key = rng.randi_range(0, rewards.size() - 1)
	var count = 1
	item_get.emit(rewards[key].name, count)

func _on_body_entered(body):
	if state != ActionState.COMPLETE:
		$Icon.visible = true
		$Sprite.texture = Highlight

func _on_body_exited(body):
	$Sprite.texture = Idle
	if state != ActionState.COMPLETE:
		$Icon.visible = false
		$Control.visible = false

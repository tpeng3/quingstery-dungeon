extends Area2D

enum ActionState { 
	IDLE,
	FISHING,
	CAUGHT,
	COMPLETE,
	FAIL
}
var state = ActionState.IDLE
var chara
var rng = RandomNumberGenerator.new()
var rewards = []

@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")
@onready var Inventory = get_node("/root/Inventory")

signal item_get

func _ready():
	var location = "Throat" # TODO: make enum or typecheck
	rewards = Inventory.get_items_json().filter(
		func(i): return i.source == location and i.category == "Fishing"
	)
	
	$Timer.timeout.connect(_on_fish_bait)

func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	# on enter/space or mouse click
	if Input.is_action_just_pressed("ui_accept") and chara and state == ActionState.IDLE:
		state = ActionState.FISHING
		$Icon.visible = false
		chara.get_node("Bubble").play("Waiting")
		chara.get_node("Bubble").visible = true
		# TODO: add mining values and difficulty
		# TODO: reduce hunger when mining
		rng.randomize()
		var wait = rng.randf_range(3, 5)
		$Timer.wait_time = wait
		$Timer.start()
		Global.currentHunger -= 0.5
	elif Input.is_action_just_pressed("ui_accept") and chara and state == ActionState.CAUGHT:
		_on_fishing_complete()
		
func _on_fish_bait():
	if chara:
		chara.get_node("Bubble").play("Catch")
		state = ActionState.CAUGHT
		var wait = rng.randf_range(0, 1)
		$ReelTimer.start()
		await $ReelTimer.timeout
		if state != ActionState.COMPLETE:
			state = ActionState.FAIL
			$Sprite/Sparkle.visible = false
			if chara:
				chara.get_node("Bubble").play("Failure")
				await chara.get_node("Bubble").animation_finished
				chara.get_node("Bubble").visible = false

func _on_fishing_complete():
	state = ActionState.COMPLETE
	$Sprite/Sparkle.visible = false
	$Sprite.play("idle")
	chara.get_node("Bubble").play("Success")
	await chara.get_node("Bubble").animation_finished
	chara.get_node("Bubble").visible = false
	Global.currentHunger -= 2
	if DialogueBox:
		rng.randomize()
		var key = rng.randi_range(0, rewards.size() - 1)
		var count = 1
		DialogueBox.show_new_item(rewards[key].name, count)
		# TODO: generate random item, with a count range and dependent on location

func _on_body_entered(body):
	if body.name == "Quingee":
		chara = body
		if state == ActionState.IDLE:
			$Sprite.play("highlight")
			$Icon.visible = true

func _on_body_exited(body):
	$Sprite.play("idle")
	if body.name == "Quingee":
		$Icon.visible = false
		chara.get_node("Bubble").visible = false
		chara = null
		if state == ActionState.FISHING:
			state = ActionState.IDLE

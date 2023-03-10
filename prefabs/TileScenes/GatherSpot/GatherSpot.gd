extends Area2D

enum ActionState { 
	IDLE,
	COMPLETE
}
var state = ActionState.IDLE
var rewards = []
var rng = RandomNumberGenerator.new()

@onready var Idle = preload("res://assets/tile/Forage_Gather_Field_Sprite2.png")
@onready var Highlight = preload("res://assets/tile/Forage_Gather_Field_Sprite1.png")
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")
@onready var Inventory = get_node("/root/Inventory")

signal item_get

func _ready():
	var location = "Throat" # TODO: make enum or typecheck
	rewards = Inventory.get_items_json().filter(
		func(i): return i.source == location and i.category == "Gathering"
	)
	
	$Timer.timeout.connect(_on_gathering)

func _input(event):
	# on enter/space or mouse click
	if Input.is_action_just_pressed("ui_accept") and has_overlapping_bodies() \
		and state != ActionState.COMPLETE:
		$Icon.visible = false
		$Control.visible = true
		$Timer.start()
		# TODO: add gather values and difficulty
		# TODO: reduce hunger when mining

func _on_gathering():
	if Input.is_action_pressed("ui_accept") and has_overlapping_bodies():
		$Control/ProgressBar.value += 1
		if $Control/ProgressBar.value >= $Control/ProgressBar.max_value:
			_on_gathering_complete()
		$Timer.start()

func _on_gathering_complete():
	$Timer.timeout.disconnect(_on_gathering)
	state = ActionState.COMPLETE
	$Sprite/Sparkle.visible = false
	$Control.visible = false
	$Sprite.texture = Idle
	if DialogueBox:
		rng.randomize()
		var key = rng.randi_range(0, rewards.size() - 1)
		var count = 1
#		$DialoguePlayer.data.lines.text.replace("[[amount]]", str(count))
#		$DialoguePlayer.data.lines.text.replace("[[item]]", str(rewards[key].name))
#		$DialoguePlayer.data.lines.action[1] = rewards[key].path
		DialogueBox.show_dialogue($DialoguePlayer)
		Inventory.add_item(rewards[key].name, count)
		# TODO: generate random item, with a count range and dependent on location

func _on_body_entered(body):
	if state != ActionState.COMPLETE:
		$Icon.visible = true
		$Timer.stop()
		$Sprite.texture = Highlight

func _on_body_exited(body):
	$Sprite.texture = Idle
	if state != ActionState.COMPLETE:
		$Timer.stop()
		state = ActionState.IDLE
		$Icon.visible = false
		$Control.visible = false

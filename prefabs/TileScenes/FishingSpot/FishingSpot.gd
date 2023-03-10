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
signal item_get
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")

func _ready():
	$Timer.timeout.connect(_on_fish_bait)
	pass # Replace with function body.

func _input(event):
	# on enter/space or mouse click
	if Input.is_action_just_pressed("ui_accept") and chara and state == ActionState.IDLE:
		state = ActionState.FISHING
		$Icon.visible = false
		chara.get_node("PlaceholderText").text = "Waiting..."
		chara.get_node("PlaceholderText").visible = true
		# TODO: add mining values and difficulty
		# TODO: reduce hunger when mining
		rng.randomize()
		var wait = rng.randf_range(3, 5)
		$Timer.wait_time = wait
		$Timer.start()
	elif Input.is_action_just_pressed("ui_accept") and chara and state == ActionState.CAUGHT:
		_on_fishing_complete()
		
func _on_fish_bait():
	if chara:
		chara.get_node("PlaceholderText").text = "Press space to reel"
		state = ActionState.CAUGHT
		var wait = rng.randf_range(0, 1)
		$ReelTimer.start()
		await $ReelTimer.timeout
		if state != ActionState.COMPLETE:
			state = ActionState.FAIL
			$Sprite/Sparkle.visible = false
			if chara:
				chara.get_node("PlaceholderText").visible = false

func _on_fishing_complete():
	state = ActionState.COMPLETE
	$Sprite/Sparkle.visible = false
	chara.get_node("PlaceholderText").visible = false
	if DialogueBox:
		DialogueBox.show_dialogue($DialoguePlayer)
		var item = "Glowbug Lantern"
		# TODO: generate random item

func _on_body_entered(body):
	if body.name == "Quingee":
		chara = body
		if state == ActionState.IDLE:
			$Icon.visible = true

func _on_body_exited(body):
	if body.name == "Quingee":
		$Icon.visible = false
		chara.get_node("PlaceholderText").visible = false
		chara = null
		if state == ActionState.FISHING:
			state = ActionState.IDLE

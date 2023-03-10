extends Area2D

enum ActionState { 
	IDLE,
	COMPLETE
}
var state = ActionState.IDLE
signal item_get
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")

func _ready():
	$Timer.timeout.connect(_on_gathering)

func _input(event):
	# on enter/space or mouse click
	if Input.is_action_just_pressed("ui_accept") and has_overlapping_bodies():
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
	if DialogueBox:
		DialogueBox.show_dialogue($DialoguePlayer)
		var item = "Foraging item"
		# TODO: generate random item

func _on_body_entered(body):
	if state != ActionState.COMPLETE:
		$Icon.visible = true
		$Timer.stop()

func _on_body_exited(body):
	if state != ActionState.COMPLETE:
		$Timer.stop()
		state = ActionState.IDLE
		$Icon.visible = false
		$Control.visible = false

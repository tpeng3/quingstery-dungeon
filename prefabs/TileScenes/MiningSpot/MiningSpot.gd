extends Area2D

enum ActionState { 
	IDLE,
	COMPLETE
}
var state = ActionState.IDLE
signal item_get
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")

func _ready():
	pass # Replace with function body.

func _input(event):
	# on enter/space or mouse click
	if event.is_action_pressed("ui_accept") and has_overlapping_bodies():
		$Icon.visible = false
		$Icon/AnimationPlayer.pause()
		$Control.visible = true
		# TODO: add mining values and difficulty
		# TODO: reduce hunger when mining
		$Control/ProgressBar.value += 1
		if $Control/ProgressBar.value >= $Control/ProgressBar.max_value:
			_on_mining_complete()

func _on_mining_complete():
	state = ActionState.COMPLETE
	$Sprite/Sparkle.visible = false
	$Control.visible = false
	if DialogueBox:
		DialogueBox.show_dialogue($DialoguePlayer)
		var item = "Glowbug Lantern"
		# TODO: generate random item

func _on_body_entered(body):
	if state != ActionState.COMPLETE:
		$Icon.visible = true

func _on_body_exited(body):
	if state != ActionState.COMPLETE:
		$Icon.visible = false
		$Control.visible = false

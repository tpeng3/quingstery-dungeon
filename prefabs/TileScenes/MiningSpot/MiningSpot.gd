extends Area2D

@export var Idle:Texture2D
@export var Highlight:Texture2D
@export var request:String
@export var reward:String
@export var reward_num:int = 1
@export_multiline var popup_text:String
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")

var rng = RandomNumberGenerator.new()
var startingkey = "hello1"
var hasTraded = false

func _ready():
	rng.randomize()
	var randomIndex = rng.randi_range(0, 1)
	startingkey = ["hello1", "hello2"][randomIndex]
	
func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	# on enter/space or mouse click
	if event.is_action_pressed("ui_accept") and has_overlapping_bodies() and not DialogueBox.visible:
		$Icon.visible = false
		$AnimationPlayer.pause()
		
		# check if user has request item
		if request in Inventory.inventory:
			DialogueBox.yes_selected.connect(_on_yes_selected)
			DialogueBox.no_selected.connect(_on_no_selected)
			if hasTraded:
				DialogueBox.show_dialogue($DialoguePlayer, "trade more")
			else:
				DialogueBox.show_dialogue($DialoguePlayer, startingkey)
		else:
			if hasTraded:
				DialogueBox.show_dialogue($DialoguePlayer, "no more trading")
			else:
				DialogueBox.show_dialogue($DialoguePlayer, "no item")

func _on_yes_selected():
	DialogueBox.yes_selected.disconnect(_on_yes_selected)
	DialogueBox.no_selected.disconnect(_on_no_selected)
	Inventory.remove_item(request)
	DialogueBox.show_new_item(reward, reward_num, popup_text.replace("[request]", request))
	hasTraded = true

func _on_no_selected():
	DialogueBox.yes_selected.disconnect(_on_yes_selected)
	DialogueBox.no_selected.disconnect(_on_no_selected)

func _on_body_entered(body):
	$Icon.visible = true
	$Sprite.texture = Highlight

func _on_body_exited(body):
	$Sprite.texture = Idle
	$Icon.visible = false

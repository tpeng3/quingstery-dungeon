extends Area2D

@export var Idle:Texture2D
@export var Highlight:Texture2D
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DungeonBox")

var rng = RandomNumberGenerator.new()
var talkkey = null
var hasTraded = false
var chara = null

func _ready():
	talkkey = _weighted_rand("welcome")
	DialogueBox.no_selected.connect(_on_dialogue_finished)
	_on_body_exited(null)
	
func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	# on enter/space or mouse click
	if event.is_action_released("ui_accept") and chara and not DialogueBox.visible:
		$Icon.visible = false
		$AnimationPlayer.pause()
		DialogueBox.show_dialogue($DialoguePlayer, talkkey)

func _on_body_entered(body):
	if body and body.name == "Quingee":
		chara = body
		$Icon.visible = true
		$Sprite.texture = Highlight

func _on_body_exited(body):
	if body and body.name == "Quingee":
		chara = null
		$Sprite.texture = Idle
		$Icon.visible = false
	
func _on_dialogue_finished():
	if talkkey == "Cashew sprite random dialogue 6":
		var item_array = ["Seed Packet", "Silk", "Acorn", "Art", "Herb Bundle", "Jewel"]
		var item = item_array[randi() % item_array.size()]
		DialogueBox.show_new_item(item)
		talkkey = "Cashew sprite random dialogue 7"

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			return i.type == "cashew" or i.type == "cashew gift" or \
				(i.type == "cashew outfit" and Inventory.equipped.size() > 0)
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.cashew[a.key] if a.key in Global.dialogue_popularity.cashew else 0
			var bPop = Global.dialogue_popularity.cashew[b.key] if b.key in Global.dialogue_popularity.cashew else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.cashew:
		Global.dialogue_popularity.cashew[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.cashew[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

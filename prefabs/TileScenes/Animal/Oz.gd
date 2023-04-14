extends Area2D

@export var Idle:Texture2D
@export var Highlight:Texture2D
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data

var rng = RandomNumberGenerator.new()

func _ready():
	$ShopBox.no_selected.connect(_on_dialogue_end)

func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	# on enter/space or mouse click
	if event.is_action_released("ui_accept") and has_overlapping_bodies() and not $ShopBox.visible:
		Global.freezeQuingee = true
		$Icon.visible = false
		$AnimationPlayer.pause()
		on_talk()
		
func on_talk():
	$ShopBox.enter_shop()
	if Global.FP.oz >= 6:
		$ShopBox.show_dialogue($DialoguePlayer, "oz6")
	else:
		$ShopBox.show_dialogue($DialoguePlayer, "oz" + str(Global.FP.oz + 1))
	
func _on_dialogue_end():
	Global.FP.oz += 1
	Global.currentHunger = Global.maxHunger
	var message = "After a short break and (truthfully unappetizing) meal, you feel well-rested and ready to continue your journey."
	await SceneManager.fade_with_text(message)
	Global.advanceFloor()

func _on_body_entered(body):
	$Icon.visible = true
	$Sprite.texture = Highlight

func _on_body_exited(body):
	$Sprite.texture = Idle
	$Icon.visible = false

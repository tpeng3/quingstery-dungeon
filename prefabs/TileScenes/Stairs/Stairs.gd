extends Area2D

signal on_stairs

var entered_stairs = false
@onready var Idle = preload("res://assets/tile/Stair_Tile_2.png")
@onready var Highlight = preload("res://assets/tile/Stair_Tile1.png")
@onready var DialogueBox = get_parent().get_parent().get_parent().get_node("DialogueBox")

func _input(event):
	if (event.is_action_pressed("ui_accept")) and entered_stairs:
		print(DialogueBox)
		if DialogueBox:
			DialogueBox.show_dialogue($DialoguePlayer)
			DialogueBox.yes_selected.connect(_on_yes_selected)
			DialogueBox.no_selected.connect(_on_no_selected)

func _on_body_entered(body):
	$PlaceholderText.visible = true
	entered_stairs = true
	$Sprite.texture = Highlight

func _on_body_exited(body):
	$PlaceholderText.visible = false
	entered_stairs = false
	$Sprite.texture = Idle

func _on_yes_selected():
	emit_signal("on_stairs")

func _on_no_selected():
	DialogueBox.yes_selected.disconnect(_on_yes_selected)
	DialogueBox.no_selected.disconnect(_on_no_selected)

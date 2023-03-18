extends Node2D

@export var scene: String

enum MapLayer { 
	FLOOR,
	ITEMS
}

var seenHungry = false
var seenFamished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.currentHunger = Global.maxHunger
	
	# wait until tilemap is ready to connect signals
	call_deferred("_connect_tiles")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.freezeQuingee:
		return
	
	if Global.currentHunger <= Global.maxHunger/2 and not seenHungry:
		$DialogueBox.show_dialogue($DialogueNodes/HungryDialogue)
		seenHungry = true
		
	if Global.currentHunger <= 5 and not seenFamished:
		$DialogueBox.show_dialogue($DialogueNodes/FamishedDialogue)
		seenFamished = true
	
	## TODO: show cutscene at the fire station
	if Global.currentHunger <= 0:
#		scene = "YouDied"
		SceneManager.change_scene(scene)
	
func _connect_tiles():
	for tile in $Map/Floor.get_children():
		match tile.name:
			"Stairs":
				tile.on_stairs.connect(_next_floor)

func _next_floor():
	SceneManager.change_scene(scene)

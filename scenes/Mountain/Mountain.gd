extends Node2D

@export var scene: String
@export var music:AudioStream

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
	
	$CanvasLayer/FloorInfo.text = Global.get_checkpoint_name() + " " + str(Global.currentFloor) + "F"
	$AnimationPlayer.play("new_floor")
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play_backwards("new_floor")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.freezeQuingee:
		return
	
	if Global.currentHunger <= Global.maxHunger/2 and not seenHungry:
		$DungeonBox.show_dialogue($DialoguePlayer, "hungry")
		seenHungry = true
		
	if Global.currentHunger <= 5 and not seenFamished:
		$DungeonBox.show_dialogue($DialoguePlayer, "famished")
		seenFamished = true
	
	## TODO: show cutscene at the fire station
	if Global.currentHunger <= 0:
#		scene = "YouDied"
		SceneManager.change_scene(scene)
	
func _connect_tiles():
	for tile in $Map/Floor.get_children():
		if tile.has_signal("item_get"):
			tile.item_get.connect(_on_item_get, CONNECT_ONE_SHOT)
		if tile.has_signal("find_stairs"):
			tile.find_stairs.connect(_find_stairs)

func _on_item_get(item, amount):
	$DungeonBox.show_new_item(item, amount)

func _find_stairs():
	$DungeonBox.show_dialogue($DialoguePlayer, "stairs")
	$DungeonBox.yes_selected.connect(_next_floor, CONNECT_ONE_SHOT)

func _next_floor():
	Global.freezeQuingee = false
	Global.advanceFloor()

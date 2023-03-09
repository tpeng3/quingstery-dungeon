extends Node2D

# TODO: we don't need all these options, clean it up
@export var scene: String
@export var fade_out_speed: float = 0.5
@export var fade_in_speed: float = 0.5
@export var fade_out_pattern: String = "fade"
@export var fade_in_pattern: String = "fade"
@export var fade_out_smoothness = 0.1 # (float, 0, 1)
@export var fade_in_smoothness = 0.1 # (float, 0, 1)
@export var fade_out_inverted: bool = false
@export var fade_in_inverted: bool = false
@export var color: Color = Color(0, 0, 0)
@export var timeout: float = 0.0
@export var clickable: bool = false
@export var add_to_back: bool = true

@onready var fade_out_options = SceneManager.create_options(fade_out_speed, fade_out_pattern, fade_out_smoothness, fade_out_inverted)
@onready var fade_in_options = SceneManager.create_options(fade_in_speed, fade_in_pattern, fade_in_smoothness, fade_in_inverted)
@onready var general_options = SceneManager.create_general_options(color, timeout, clickable, add_to_back)

enum MapLayer { 
	FLOOR,
	ITEMS
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# wait until tilemap is ready to connect signals
	call_deferred("_connect_tiles")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _connect_tiles():
	for tile in $Map/Floor.get_children():
		match tile.name:
			"FishingSpot":
				tile.item_get.connect(_on_item_get)
			"GatheringSpot":
				tile.item_get.connect(_on_item_get)
			"MiningSpot":
				tile.item_get.connect(_on_item_get)
			"Stairs":
				tile.on_stairs.connect(_next_floor)

func _on_item_get(item):
	print(item)
	
func _next_floor():
	$DialogueBox.visible = false
	SceneManager.change_scene(scene, fade_out_options, fade_in_options, general_options)

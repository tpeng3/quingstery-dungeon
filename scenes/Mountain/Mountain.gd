extends Node2D

@export var tilemap: Node

@export var scene: String
@export var fade_out_speed: float = 1.0
@export var fade_in_speed: float = 1.0
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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var interact = $Walls/Quingee.get_slide_collision_count()
	
	if interact > 0:
		$PlaceholderText.visible = true
		if (Input.is_action_just_released("ui_accept")):
			var rid = $Walls/Quingee.get_last_slide_collision().get_collider_rid()
			var coord = $Floor.get_coords_for_body_rid(rid)
			var tile_id = $Floor.get_cell_source_id(1, coord)
			# TODO: I think we can map the tile ID to something more readable
			if tile_id == 7:
				SceneManager.change_scene(scene, fade_out_options, fade_in_options, general_options)
	else:
		$PlaceholderText.visible = false
	pass

extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var last_direction = "down"
var hunger_steps = 0
var hunger_interval = 1
var last_position = Vector2(0, 0)
var scraaing = false

func _ready():
	pass
	
func _input(event):
	if Input.is_action_pressed("scraa"):
		if not $AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
		scraaing = true
	else:
		$AudioStreamPlayer2D.stop()

func _physics_process(_delta):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	set_velocity(motion)
	move_and_slide()
	
	# add steps
	hunger_steps += self.global_position.distance_to(last_position)
	last_position = self.global_position
	if hunger_steps >= hunger_interval * MOTION_SPEED:
		hunger_steps = 0
		Global.currentHunger -= 1
		
	var modifier = "scraa" if Input.is_action_pressed("scraa") else ""
	var modifier2 = "scraa" if Input.is_action_pressed("scraa") else "default"
	$Camera2D.trauma = 1.0 if Input.is_action_pressed("scraa") else 0
	
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		$Sprite.play(modifier + "upright")
		last_direction = "upright"
	elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		$Sprite.play(modifier + "upleft")
		last_direction = "upleft"
	elif Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		$Sprite.play(modifier + "downright")
		last_direction = "downright"
	elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		$Sprite.play(modifier + "downleft")
		last_direction = "downleft"
	elif Input.is_action_pressed("move_up"):
		$Sprite.play(modifier + "up")
		last_direction = "up"
	elif Input.is_action_pressed("move_down"):
		$Sprite.play(modifier + "down")
		last_direction = "down"
	elif Input.is_action_pressed("move_left"):
		$Sprite.play(modifier + "left")
		last_direction = "left"
	elif Input.is_action_pressed("move_right"):
		$Sprite.play(modifier + "right")
		last_direction = "right"
	else:
		$Sprite.play(modifier2 + last_direction)

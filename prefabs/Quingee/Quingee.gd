extends CharacterBody2D

const MOTION_SPEED = 160 # Pixels/second.
var last_direction = "defaultdown"

func _physics_process(_delta):
	var motion = Vector2()
	motion.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	motion.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	motion.y /= 2
	motion = motion.normalized() * MOTION_SPEED
	#warning-ignore:return_value_discarded
	set_velocity(motion)
	move_and_slide()
	
	if Input.is_action_pressed("move_right") and Input.is_action_pressed("move_up"):
		$Sprite.play("upright")
		last_direction = "defaultupright"
	elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_up"):
		$Sprite.play("upleft")
		last_direction = "defaultupleft"
	elif Input.is_action_pressed("move_right") and Input.is_action_pressed("move_down"):
		$Sprite.play("downright")
		last_direction = "defaultdownright"
	elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_down"):
		$Sprite.play("downleft")
		last_direction = "defaultdownleft"
	elif Input.is_action_pressed("move_up"):
		$Sprite.play("up")
		last_direction = "defaultup"
	elif Input.is_action_pressed("move_down"):
		$Sprite.play("down")
		last_direction = "defaultdown"
	elif Input.is_action_pressed("move_left"):
		$Sprite.play("left")
		last_direction = "defaultleft"
	elif Input.is_action_pressed("move_right"):
		$Sprite.play("right")
		last_direction = "defaultright"
	else:
		$Sprite.play(last_direction)

extends MarginContainer

var quingPosition = 365

func _ready():
	update_progress()
	
func update_progress():
	$ClimbProgress/Throat/Label.text = str(Global.CheckpointType.THROAT) if \
		Global.currentCheckpoint > Global.CheckpointType.THROAT else "??"
	$ClimbProgress/River/Label.text = str(Global.CheckpointType.RIVER) if \
		Global.currentCheckpoint > Global.CheckpointType.RIVER else "??"
	$ClimbProgress/Steps/Label.text = str(Global.CheckpointType.STEPS) if \
		Global.currentCheckpoint > Global.CheckpointType.STEPS else "??"
	$ClimbProgress/Peak/Label.text = str(Global.CheckpointType.PEAK) if \
		Global.currentCheckpoint > Global.CheckpointType.PEAK else "??"
	$ClimbProgress/Crown/Label.text = str(Global.CheckpointType.TOP) if \
		Global.currentCheckpoint > Global.CheckpointType.TOP else "??"
		
	$ClimbProgress/River.region_rect = Rect2(16, 72 - (18*2), 18, 18) if \
		Global.currentCheckpoint > Global.CheckpointType.RIVER else Rect2(16, 72, 18, 18)
	$ClimbProgress/Steps.region_rect = Rect2(16, 72 - (18*3), 18, 18) if \
		Global.currentCheckpoint > Global.CheckpointType.STEPS else Rect2(16, 72, 18, 18)
	$ClimbProgress/Peak.region_rect = Rect2(16, 72 - ( 18*4), 18, 18) if \
		Global.currentCheckpoint > Global.CheckpointType.PEAK else Rect2(16, 72, 18, 18)
	
	
	$ClimbProgress/QuingProgress/Label.text = str(Global.currentFloor)
	
	if (Global.currentFloor == Global.CheckpointType.TOP):
		$ClimbProgress.value = 100
		
	elif (Global.currentFloor >= Global.CheckpointType.PEAK):
		# the current amount of steps past the previous checkpoint
		# multiplied by 25, the length of the next section of the bar
		# divided by the amt of steps between this and next checkpoint
		$ClimbProgress.value = 75.0 \
		+ ((Global.currentFloor - Global.CheckpointType.PEAK) * 25.0 \
		/ (Global.CheckpointType.TOP - Global.CheckpointType.PEAK))
		
	elif (Global.currentFloor >= Global.CheckpointType.STEPS):
		$ClimbProgress.value = 50 \
		+ ((Global.currentFloor - Global.CheckpointType.STEPS) * 25.0 \
		/ (Global.CheckpointType.PEAK - Global.CheckpointType.STEPS))
		
	elif (Global.currentFloor >= Global.CheckpointType.RIVER):
		$ClimbProgress.value = 25 \
		+ ((Global.currentFloor - Global.CheckpointType.RIVER ) * 25.0 \
		/ (Global.CheckpointType.STEPS - Global.CheckpointType.RIVER))
	else:
		$ClimbProgress.value = (Global.currentFloor * 25.0 / Global.CheckpointType.RIVER)
		
	# sets bar position by reversing value and multiplying to scale to height
	$ClimbProgress/QuingProgress.position = Vector2(26, (100 - $ClimbProgress.value) * 3.6) 

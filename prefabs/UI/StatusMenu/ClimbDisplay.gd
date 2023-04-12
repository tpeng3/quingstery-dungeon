extends MarginContainer

var quingPosition = 365

func _ready():
	$ClimbProgress.max_value = Global.CheckpointType.TOP
	update_progress()
	
func _process(delta):
	pass
	
func update_progress():
	$ClimbProgress/Throat/Label.text = str(Global.CheckpointType.THROAT) if \
		Global.currentCheckpoint >= Global.CheckpointType.THROAT else "??"
	$ClimbProgress/River/Label.text = str(Global.CheckpointType.RIVER) if \
		Global.currentCheckpoint >= Global.CheckpointType.RIVER else "??"
	$ClimbProgress/Steps/Label.text = str(Global.CheckpointType.STEPS) if \
		Global.currentCheckpoint >= Global.CheckpointType.STEPS else "??"
	$ClimbProgress/Peak/Label.text = str(Global.CheckpointType.PEAK) if \
		Global.currentCheckpoint >= Global.CheckpointType.PEAK else "??"
	$ClimbProgress/Crown/Label.text = str(Global.CheckpointType.TOP) if \
		Global.currentCheckpoint >= Global.CheckpointType.TOP else "??"
		
	$ClimbProgress/River.region_rect = Rect2(16, 72 - (18*2), 18, 18) if \
		Global.currentCheckpoint >= Global.CheckpointType.RIVER else Rect2(16, 72, 18, 18)
	$ClimbProgress/Steps.region_rect = Rect2(16, 72 - (18*3), 18, 18) if \
		Global.currentCheckpoint >= Global.CheckpointType.RIVER else Rect2(16, 72, 18, 18)
	$ClimbProgress/Peak.region_rect = Rect2(16, 72 - ( 18*4), 18, 18) if \
		Global.currentCheckpoint >= Global.CheckpointType.RIVER else Rect2(16, 72, 18, 18)
	
	$ClimbProgress/QuingProgress/Label.text = str(Global.currentFloor)
	$ClimbProgress/QuingProgress.position = Vector2(26, quingPosition - (1.0 * Global.currentFloor / Global.CheckpointType.TOP) * quingPosition)
	$ClimbProgress.value = Global.currentFloor
	

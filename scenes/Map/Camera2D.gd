extends Camera2D

var focused_location

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused_location:
		position_smoothing_enabled = false
		position = Vector2(200, 100)
		position_smoothing_enabled = true

extends Camera2D

var focused_location

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused_location:
		position = Vector2(
			min(focused_location.position.x - (960/2) - 230, 1225 - (960/2) - 80),
			focused_location.position.y - (540/2) + 80
		)

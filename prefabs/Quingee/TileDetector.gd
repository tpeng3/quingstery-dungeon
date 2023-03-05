class_name TileDetector
extends Area2D

func _on_TileDetector_body_entered(body):
	if body is TileMap:
		if body.get_parent().has_method("add_active_body"):
			body.get_parent().add_active_body(self)

# bug/strange behavior:
# area2ds fire body_exited when tilemap set_cell is called
# https://github.com/godotengine/godot/issues/61220
# func _on_TileDetector_body_exited(body:Node):
#   if body is TileMap:
#     if body.get_parent().has_method("remove_active_body"):
#       body.get_parent().remove_active_body(self)

# Returns an array of vector2s (the overlapping tilemap cell coords)
func overlapping_cells(tm: TileMap) -> Array:
	# TODO may need to support more shapes here
	var extents = $CollisionShape2D.shape.extents
	var first_cell = tm.local_to_map(global_position - extents)
	var last_cell = tm.local_to_map(global_position + extents)
	var cells = []
	print(tm)
	for x in range(first_cell.x, last_cell.x + 1):
		for y in range(first_cell.y, last_cell.y + 1):
			cells.append(Vector2(x, y))
	return cells

extends TextureButton

enum Direction {
	RIGHT,
	LEFT,
	UP,
	DOWN
}
@export var direction:Direction = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_normal.region = Rect2(0, 9 * direction, 9, 9)
	texture_focused.region = Rect2(27, 9 * direction, 9, 9)
	texture_pressed.region = Rect2(9, 9 * direction, 9, 9)
	texture_disabled.region = Rect2(18, 9 * direction, 9, 9)

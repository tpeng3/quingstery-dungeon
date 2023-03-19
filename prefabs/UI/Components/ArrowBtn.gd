@tool
extends TextureButton
var direction = 0;
var sprite = AtlasTexture.new()
var spriteFocus = AtlasTexture.new()
var spritePress = AtlasTexture.new()
var spriteDisabled = AtlasTexture.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	var dir = get_meta("Direction").to_lower()
	
	match (dir): # multiplier for Y position of Atlas texture
		"left":
			direction = 1
		"up":
			direction = 2
		"down":
			direction = 3
		_:
			direction = 0
	
	sprite.atlas = load("res://assets/ui/arrows.png")
	sprite.region = Rect2(0, 9 * direction, 9, 9)
	self.texture_normal = sprite
	
	spriteFocus.atlas = load("res://assets/ui/arrows.png")
	spriteFocus.region = Rect2(27, 9 * direction, 9, 9)
	self.texture_focused = spriteFocus
	
	spritePress.atlas = load("res://assets/ui/arrows.png")
	spritePress.region = Rect2(9, 9 * direction, 9, 9)
	self.texture_pressed = spritePress
	
	spriteDisabled.atlas = load("res://assets/ui/arrows.png")
	spriteDisabled.region = Rect2(18, 9 * direction, 9, 9)
	self.texture_disabled = spriteDisabled

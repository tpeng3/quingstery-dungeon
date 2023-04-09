extends TextureButton
const btnSize = 48

var sprite = AtlasTexture.new()
var spriteFocus = AtlasTexture.new()
var spriteFocusActive = AtlasTexture.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var vertPosition = 0
	
	sprite.atlas = load("res://assets/ui/Icon_Menu.png")
	spriteFocus.atlas = load("res://assets/ui/Icon_Menu.png")
	spriteFocusActive.atlas = load("res://assets/ui/Icon_Menu.png")
	
	sprite.region = Rect2(0, vertPosition * btnSize, btnSize, btnSize)
	spriteFocusActive.region = Rect2(btnSize, vertPosition * btnSize, btnSize, btnSize)
	spriteFocus.region = Rect2(btnSize * 3, vertPosition * btnSize, btnSize, btnSize)
	
	self.texture_normal = sprite
	self.texture_focused = spriteFocus
	self.texture_disabled = sprite
	

func _on_toggled(value):
	if value:
		self.texture_focused = spriteFocus
	else:
		self.texture_focused = spriteFocusActive

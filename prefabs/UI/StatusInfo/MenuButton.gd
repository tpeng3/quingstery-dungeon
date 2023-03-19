@tool
extends TextureButton
const btnSize = 48

var sprite = AtlasTexture.new()
var spriteFocus = AtlasTexture.new()
var spriteActive = AtlasTexture.new()
var spriteFocusActive = AtlasTexture.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	var vertPosition = get_meta("vertPosition")
	
	sprite.atlas = load("res://assets/ui/Icon_Menu.png")
	spriteFocus.atlas = load("res://assets/ui/Icon_Menu.png")
	spriteActive.atlas = load("res://assets/ui/Icon_Menu.png")
	spriteFocusActive.atlas = load("res://assets/ui/Icon_Menu.png")
	
	sprite.region = Rect2(0, vertPosition * btnSize, btnSize, btnSize)
	spriteFocus.region = Rect2(btnSize, vertPosition * btnSize, btnSize, btnSize)
	spriteActive.region = Rect2(btnSize * 2, vertPosition * btnSize, btnSize, btnSize)
	spriteFocusActive.region = Rect2(btnSize * 3, vertPosition * btnSize, btnSize, btnSize)
	
	self.texture_normal = sprite
	self.texture_pressed = spriteActive
	self.texture_focused = spriteFocus
	self.texture_disabled = sprite
	
	pass # Replace with function body.


func _on_focus_entered():
	self.texture_normal = spriteFocus
	self.texture_pressed = spriteFocusActive
	
	
func _on_focus_exited():
	self.texture_normal = sprite
	self.texture_pressed = spriteActive


func _on_toggled(button_pressed):
	if button_pressed:
		self.texture_focused = spriteFocusActive
	else:
		self.texture_focused = spriteFocus
	pass # Replace with function body.

@tool
extends TextureButton

@export var vertPosition = 0
const btnSize = 48

@onready var sprite = Rect2(0, vertPosition * btnSize, btnSize, btnSize)
@onready var spriteFocus = Rect2(btnSize, vertPosition * btnSize, btnSize, btnSize)
@onready var spriteActive = Rect2(btnSize * 2, vertPosition * btnSize, btnSize, btnSize)
@onready var spriteFocusActive = Rect2(btnSize * 3, vertPosition * btnSize, btnSize, btnSize)

func _on_focus_entered():
	self.texture_normal.region = spriteFocus
	self.texture_pressed.region = spriteFocusActive
	self.texture_focused.region = spriteFocus

func _on_focus_exited():
	self.texture_normal.region = sprite
	self.texture_pressed.region = spriteActive
	self.texture_focused.region = spriteFocusActive

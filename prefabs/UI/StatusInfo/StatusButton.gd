extends TextureButton
const btnSize = 48
	
func _on_toggled(value):
	var vertPosition = 0
	if value:
		self.texture_focused.region = Rect2(btnSize * 3, vertPosition * btnSize, btnSize, btnSize)
	else:
		self.texture_focused.region = Rect2(btnSize, vertPosition * btnSize, btnSize, btnSize)

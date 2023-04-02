extends Node

@export var Background:Node

# show weather effects
func show_weather():
	match Global.currentWeather:
		"Rainy":
			$Panel.modulate = Color(0.22, 0.31, 0.35, 0.35)
			Background.modulate = Color(0.7, 0.83, 0.95, 1)
			$RainParticles.amount = 100
			$RainParticles.show()
		"Stormy":
			$Panel.modulate = Color(0.15, 0.15, 0.18, 0.58)
			Background.modulate = Color(0.73, 0.83, 0.93, 1)
			$RainParticles.amount = 300
			$RainParticles.show()
			$LeafParticles.show()
		"Cloudy":
			$Panel.modulate = Color(0.22, 0.31, 0.35, 0.35)
			Background.modulate = Color(0.85, 0.83, 0.84, 1)
		"Windy":
			$Panel.modulate = Color(0.5, 0.55, 0.56, 0.21)
			$LeafParticles.show()
		_:
			$Panel.hide()
			$LeafParticles.hide()
			$RainParticles.hide()

func update_rect(position):
	$LeafParticles.visibility_rect = Rect2(position.x, position.y, 200, 200)
	$RainParticles.visibility_rect = Rect2(position.x/2, position.y, 200, 200)

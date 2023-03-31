extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$OuterPadding/FlowContainer/WeatherToday/BoxContainer/WeatherContainer/Weather.play(Global.currentWeather)
	$OuterPadding/FlowContainer/WeatherTomorrow/BoxContainer/WeatherContainer/Weather.play(Global.futureWeather)
	hide()

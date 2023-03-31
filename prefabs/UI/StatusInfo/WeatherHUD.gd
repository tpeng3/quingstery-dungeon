extends Control

enum WEATHER_MAP {
	Sunny,
	Cloudy,
	Windy,
	Rainy,
	Stormy
}
const PADDING = 39;

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "day " + ("0" + str(Global.currentDay) if Global.currentDay < 10 else str(Global.currentDay))
	var region = Rect2(
		WEATHER_MAP[Global.currentWeather] * PADDING, 0,
		PADDING, PADDING
	)
	print(Global.currentWeather)
	$Sprite2D.region_rect = region

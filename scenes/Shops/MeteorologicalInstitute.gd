extends Node2D

const FRIEND_STATUS = 20
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data

func _ready():
	$ShopBox.enter_shop()
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.piper += 1
	
func _on_dialogue_end():
	$ShopBox.no_selected.disconnect(_on_dialogue_end)
	$NavButtons/NavList/Button3.grab_focus()

func _on_forecast_end():
	$ShopBox.no_selected.disconnect(_on_forecast_end)
	$ShopBox.show()
	$ShopBox/Control/Character.show()
	$ShopBox/AnimationPlayer.play("bump")	
	$WeatherDisplay.hide()
	await get_tree().create_timer(.1).timeout
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

func _on_weather_pressed():
	$ShopBox.hide()
	$NavButtons.hide()
	$ShopBox/Control/Character.hide()
	$WeatherDisplay.show()
	$ShopBox.no_selected.connect(_on_forecast_end)
	var weather_key = _weighted_rand("weather")
	$ShopBox.show_dialogue($DialoguePlayer, weather_key)
	
func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.piper < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type == "regular" and Global.FP.piper >= FRIEND_STATUS) or \
							(i.type == "regular peak" and Global.FP.piper >= FRIEND_STATUS and Global.currentCheckpoint >= Global.CheckpointType.PEAK) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"weather":
					return \
						(i.type == "forecast rainy" and "Rainy" == Global.futureWeather) or \
						(i.type == "forecast sunny" and "Sunny" == Global.futureWeather) or \
						(i.type == "forecast sunny sunny" and "Sunny" == Global.currentWeather and "Sunny" == Global.futureWeather) or \
						(i.type == "forecast rainy sunny" and "Rainy" == Global.currentWeather and "Sunny" == Global.futureWeather) or \
						(i.type == "forecast cloudy sunny" and "Cloudy" == Global.currentWeather and "Sunny" == Global.futureWeather) or \
						(i.type == "forecast stormy sunny" and "Stormy" == Global.currentWeather and "Sunny" == Global.futureWeather) or \
						(i.type == "forecast cloudy" and "Cloudy" == Global.futureWeather) or \
						(i.type == "forecast windy" and "Windy" == Global.futureWeather) or \
						(i.type == "forecast stormy" and "Stormy" == Global.futureWeather)
				"talk":
					return i.type == "talk" or \
							(i.type == "talk friend" and Global.FP.piper >= FRIEND_STATUS) or \
							(i.type == "talk Throat" and Global.currentCheckpoint >= Global.CheckpointType.THROAT) or \
							(i.type == "talk River" and Global.currentCheckpoint >= Global.CheckpointType.RIVER) or \
							(i.type == "talk Steps" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "talk Peak" and Global.currentCheckpoint >= Global.CheckpointType.PEAK) or \
							(i.type == "talkoz" and Global.FP.oz >= 1) or \
							(i.type == "talkoz2" and Global.FP.oz >= 2)
				# liked gift / disliked gift / neutral gift / milk gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.piper[a.key] if a.key in Global.dialogue_popularity.piper else 0
			var bPop = Global.dialogue_popularity.piper[b.key] if b.key in Global.dialogue_popularity.piper else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.piper:
		Global.dialogue_popularity.piper[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.piper[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

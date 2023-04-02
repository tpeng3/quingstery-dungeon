extends Node2D

const FRIEND_STATUS = 20
const BESTIE_STATUS = 40
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data

func _ready():
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.noah += 1
	$WeatherFilter.show_weather()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed():
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

func _on_buy_pressed():
	$ShopBox.hide()
	$NavButtons.hide()
	$BuyMenu.show()

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.noah < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList  and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.noah >= FRIEND_STATUS) or \
							(i.type == "regular2" and Global.FP.noah >= BESTIE_STATUS) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				# buy / liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.noah[a.key] if a.key in Global.dialogue_popularity.noah else 0
			var bPop = Global.dialogue_popularity.noah[b.key] if b.key in Global.dialogue_popularity.noah else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.noah:
		Global.dialogue_popularity.noah[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.noah[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

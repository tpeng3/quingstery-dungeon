extends Node2D

const FRIEND_STATUS = 20
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@export var shop_json:JSON
@export var shop_items = []

func _ready():
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.reinhardt += 1
	_init_shop_items()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
	$ShopBox/Control/Character.show()
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

func _on_buy_pressed():
	$ShopBox.hide()
	$NavButtons.hide()
	$BuyMenu.show_menu()

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	if dialogue_tracker[talk_key].type == "nora":
		$ShopBox/Control/Character.hide()
	else:
		$ShopBox/Control/Character.show()
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.reinhardt < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.reinhardt >= FRIEND_STATUS) or \
							(i.type == "River unlocked" and Global.currentCheckpoint >= Global.CheckpointType.RIVER) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"talk":
					return i.type == "talk" or i.type == "nora"
				"talk":
					return i.type == "talk" or (i.type == "talk friend" and Global.FP.reinhardt >= FRIEND_STATUS)
				# buy / liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.reinhardt[a.key] if a.key in Global.dialogue_popularity.reinhardt else 0
			var bPop = Global.dialogue_popularity.reinhardt[b.key] if b.key in Global.dialogue_popularity.reinhardt else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.reinhardt:
		Global.dialogue_popularity.reinhardt[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.reinhardt[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func _init_shop_items():
	if Global.daily_bakeroast_items:
		shop_items = Global.daily_bakeroast_items
	else:
		var randi_drink = []
		var randi_bread = []
		var randi_meal = []
		var randi_snack = []
		for i in shop_json.data:
			if i.condition in Global.weatherList and i.condition == Global.currentWeather:
				shop_items.push_back(i)
			elif i.condition == "Random Drink":
				randi_drink.push_back(i)
			elif i.condition == "Random Bread":
				randi_bread.push_back(i)
			elif i.condition == "Random Meal":
				randi_meal.push_back(i)
			elif i.condition == "Random Snack":
				randi_snack.push_back(i)
			else:
				shop_items.push_back(i)
		shop_items.push_back(randi_drink[randi() % randi_drink.size()])
		shop_items.push_back(randi_bread[randi() % randi_bread.size()])
		shop_items.push_back(randi_meal[randi() % randi_meal.size()])
		shop_items.push_back(randi_snack[randi() % randi_snack.size()])
		Global.daily_bakeroast_items = shop_items
	$BuyMenu.init_shop()

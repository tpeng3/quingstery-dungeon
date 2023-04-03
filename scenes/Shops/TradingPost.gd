extends Node2D

const FRIEND_STATUS = 20
const BESTIE_STATUS = 40
const SELL_MARK = 100
var sellTotal = 0
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@export var shop_json:JSON
@export var shop_items = []

func _ready():
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_buy_closed)
	$SellMenu.menu_closed.connect(_on_sell_closed)
	$SellMenu.on_sell.connect(_on_sell)
	
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.bullfrog += 1
	_init_shop_items()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_buy_closed():
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

func _on_sell_closed():
	var sell_key = _weighted_rand("sell")
	$ShopBox.show_dialogue($DialoguePlayer, sell_key)
	$NavButtons.show()
	$NavButtons/NavList/Button2.grab_focus()

func _on_buy_pressed():
	$ShopBox.hide()
	$NavButtons.hide()
	$BuyMenu.show_menu()

func _on_sell_pressed():
	sellTotal = 0
	$ShopBox.hide()
	$NavButtons.hide()
	$SellMenu.show_menu()

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")
	
func _on_sell(amount):
	sellTotal += amount
	
func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.bullfrog < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.bullfrog >= FRIEND_STATUS) or \
							(i.type == "regular2" and Global.FP.bullfrog >= BESTIE_STATUS) or \
							(i.type == "River unlocked" and Global.currentCheckpoint >= Global.CheckpointType.RIVER) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"sell":
					return i.type == "sell a lot" if sellTotal >= SELL_MARK else i.type == "sell"
				"talk":
					return i.type == "talk" or (i.type == "talk friend" and Global.FP.bullfrog >= FRIEND_STATUS)
				# buy / liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.bullfrog[a.key] if a.key in Global.dialogue_popularity.bullfrog else 0
			var bPop = Global.dialogue_popularity.bullfrog[b.key] if b.key in Global.dialogue_popularity.bullfrog else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.bullfrog:
		Global.dialogue_popularity.bullfrog[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.bullfrog[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func _init_shop_items():
	for i in shop_json.data:
		if i.condition == "Friendship with Bullfrog" and Global.FP.bullfrog < FRIEND_STATUS:
			continue
		else:
			shop_items.push_back(i)
	$BuyMenu.init_shop()

extends Node2D

const FRIEND_STATUS = 20
const BESTIE_STATUS = 40
const BUY_MARK = 100
var buyTotal = 0
var tradedSoil = false
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@export var shop_json:JSON
@export var shop_items = []

func _ready():
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	$BuyMenu.on_buy.connect(_on_buy_item)
	
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.panqing += 1
	_init_shop_items()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

func _on_buy_pressed():
	buyTotal = 0
	tradedSoil = false
	$ShopBox.hide()
	$NavButtons.hide()
	$BuyMenu.show_menu()

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _on_buy_item(item):
	print(item.item_name)
	if item.item_trade and item.item_name in ['Herb Bundle', 'Tree Sap', 'Crop']:
		tradedSoil = true
	buyTotal += item.item_cost

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.panqing < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.panqing >= FRIEND_STATUS) or \
							(i.type == "regular2" and Global.FP.panqing >= BESTIE_STATUS) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"buy":
					if buyTotal >= BUY_MARK:
						return i.type == "buy a lot"
					elif tradedSoil:
						return i.type == "trade soil"
					else:
						return i.type == "buy"
				"talk":
					return i.type == "talk" or (i.type == "talk friend" and Global.FP.panqing >= FRIEND_STATUS)
				# liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.panqing[a.key] if a.key in Global.dialogue_popularity.panqing else 0
			var bPop = Global.dialogue_popularity.panqing[b.key] if b.key in Global.dialogue_popularity.panqing else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.panqing:
		Global.dialogue_popularity.panqing[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.panqing[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func _init_shop_items():
	for i in shop_json.data:
		if i.condition == "Friendship with Zane" and Global.FP.zane < FRIEND_STATUS:
			continue
		else:
			shop_items.push_back(i)
	$BuyMenu.init_shop()

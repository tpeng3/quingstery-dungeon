extends Node2D

const FRIEND_STATUS = 10
const BESTIE_STATUS = 30
const DEATH_MARK = 5
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@export var shop_json:JSON
@export var shop_items = []

func _ready():
	$ShopBox.enter_shop()
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	
	$NavButtons.show()
	$NavButtons/NavList/Button1.grab_focus()

	Global.FP.zane += 1
	_init_shop_items()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
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
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.FP.zane < 1:
						return i.type == "tutorial"
					elif Global.FP.zane < 2:
						return i.type == "tutorial2"
					elif "Stick of Hay" in Inventory.equipped:
						return i.type == "stick of hay"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.zane >= FRIEND_STATUS) or \
							(i.type == "regular2" and Global.FP.zane >= BESTIE_STATUS) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"talk":
					if i.type == "sunny friend":
						return Global.FP.zane >= BESTIE_STATUS and Global.currentWeather == "Sunny"
					else: 
						return i.type == "talk" or \
							(i.type == "talk friend" and Global.FP.zane >= FRIEND_STATUS) or \
							(i.type == "talk friend2" and Global.FP.zane >= BESTIE_STATUS)
				"death":
					return i.type == "death" or \
						(i.type == "death2" and Global.timesFailed >= DEATH_MARK)
				# buy / liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.zane[a.key] if a.key in Global.dialogue_popularity.zane else 0
			var bPop = Global.dialogue_popularity.zane[b.key] if b.key in Global.dialogue_popularity.zane else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.zane:
		Global.dialogue_popularity.zane[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.zane[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func _init_shop_items():
	for i in shop_json.data:
		if i.type == "Upgrade" and i.condition != "None" and !i.condition in Inventory.inventory:
			continue
		else:
			shop_items.push_back(i)
	$BuyMenu.init_shop()

extends Area2D

const FRIEND_STATUS = 10
const BESTIE_STATUS = 30

@export var Idle:Texture2D
@export var Highlight:Texture2D
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
@export var shop_json:JSON
@export var shop_items = []

var rng = RandomNumberGenerator.new()

func _ready():
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$CanvasLayer/BuyMenu.menu_closed.connect(_on_menu_closed.bind(true))
	$CanvasLayer/BuyMenu.on_buy.connect(_on_buy_item)
	$CanvasLayer/SellMenu.menu_closed.connect(_on_menu_closed)
	Global.FP.wander += 1
	_init_shop_items()

func _input(event):
	# ignore input when quingee is frozen
	if Global.freezeQuingee:
		return

	# on enter/space or mouse click
	if event.is_action_released("ui_accept") and has_overlapping_bodies() and not $ShopBox.visible and not $CanvasLayer.visible:
		Global.freezeQuingee = true
		$Icon.visible = false
		$AnimationPlayer.pause()
		on_talk()

func on_talk():
	$ShopBox.enter_shop()
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$CanvasLayer.show()
	$CanvasLayer/NavButtons.show()
	$CanvasLayer/NavButtons/NavList/Button1.grab_focus()
	Global.freezeQuingee = true
	
func _on_dialogue_end():
	$CanvasLayer/NavButtons/NavList/Button3.grab_focus()
	Global.freezeQuingee = true

func _on_menu_closed(bought=false):
	var dialogue_key = _weighted_rand("buy" if bought else "sell")
	$ShopBox.show_dialogue($DialoguePlayer, dialogue_key)
	$CanvasLayer/NavButtons.show()
	$CanvasLayer/NavButtons/NavList/Button1.grab_focus()
	Global.freezeQuingee = true

func _on_buy_pressed():
	$ShopBox.hide()
	$CanvasLayer/NavButtons.hide()
	$CanvasLayer/BuyMenu.show_menu()
	Global.freezeQuingee = true

func _on_sell_pressed():
	$ShopBox.hide()
	$CanvasLayer/NavButtons.hide()
	$CanvasLayer/SellMenu.show_menu()
	Global.freezeQuingee = true

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)
	Global.freezeQuingee = true

func _on_leave_pressed():
	$ShopBox.hide()
	$CanvasLayer.hide()
	$CanvasLayer/NavButtons.hide()
	Global.freezeQuingee = false

func _on_body_entered(body):
	$Icon.visible = true
	$Sprite.texture = Highlight

func _on_body_exited(body):
	$Sprite.texture = Idle
	$Icon.visible = false

func _on_buy_item(item):
	if item.item_name in Global.lost_items:
		Global.lost_items.erase(item.item_name)

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome, weather, and lost lines
				"welcome":
					if Global.FP.wander <= 1:
						return i.type == "tutorial"
					elif Global.lost_items.size() > 0:
						return i.type == "lost" or \
							(i.type == "lost friend" and Global.FP.wander >= FRIEND_STATUS) or \
							(i.type == "lost friend2" and Global.FP.wander >= BESTIE_STATUS)
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.wander >= FRIEND_STATUS) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"talk":
					if Global.FP.wander <= 1:
						Global.FP.wander += 1
						return "talk first"
					else:
						return i.type == "talk" or \
							(i.type == "talk throat" and Global.get_checkpoint_name() == "Throat") or \
							(i.type == "talk river" and Global.get_checkpoint_name() == "River") or \
							(i.type == "talk steps" and Global.get_checkpoint_name() == "Steps") or \
							(i.type == "talk peak" and Global.get_checkpoint_name() == "Peak") or \
							(i.type == "talk friend" and Global.FP.wander >= FRIEND_STATUS) or \
							(i.type == "talk friend2" and Global.FP.wander >= BESTIE_STATUS) or \
							(i.type == "talkzane" and Global.timesFailed > 0) or \
							(i.type == "talkpiper" and Global.FP.piper > 1) or \
							(i.type == "talkoz" and Global.FP.oz > 1)
				# buy / sell / liked gift / disliked gift / neutral gift / fish gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.wander[a.key] if a.key in Global.dialogue_popularity.wander else 0
			var bPop = Global.dialogue_popularity.wander[b.key] if b.key in Global.dialogue_popularity.wander else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.wander:
		Global.dialogue_popularity.wander[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.wander[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func _init_shop_items():
	var random = []
	for i in Global.lost_items:
		shop_items.push_back({
			"item": i,
			"type": "Equip",
			"cost": 1000,
			"condition": "None"
		})
	for i in shop_json.data:
		if i.type == "Random" and (i.condition == "None" or Global.get_checkpoint_name() in i.condition):
			random.push_back(i)
		elif i.type == "Buy" or i.type == "Trade":
			if i.condition == "Friendship with Wander":
				if Global.FP.wander >= BESTIE_STATUS:
					shop_items.push_back(i)
			else:
				shop_items.push_back(i)
	random.shuffle()
	shop_items += random.slice(0, 8)
	$CanvasLayer/BuyMenu.init_shop()

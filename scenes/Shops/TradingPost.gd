extends Node2D

var rng = RandomNumberGenerator.new()
var welcome_key
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data
# TODO: move dialogue_tracker to Global

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: grab special keys 
	welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	
	$NavButtons/NavList/Button1.grab_focus()
	
func _on_dialogue_end():
	$NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$NavButtons.show()

func _on_buy_pressed():
	$ShopBox.hide()
	$NavButtons.hide()
	$BuyMenu.show()

func _on_sell_pressed():
	$NavButtons.hide()
	$ShopBox.hide()
	$BuyMenu.show()

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")

func _weighted_rand(filter):
	rng.randomize()
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			if filter:
				return i.type == filter
			else:
				return i
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			return a.popularity < b.popularity
	)
	var randInd = (round(sortedDialogue.size() / (rng.randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	sortedDialogue[randInd].popularity += 1;
	print(sortedDialogue[randInd])
	return sortedDialogue[randInd].key;

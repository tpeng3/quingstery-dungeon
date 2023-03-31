extends Node2D

var oleanderFP = 0
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
	
	$NavButtons.show()
	$SaveLoadButtons.hide()
	$StorageButtons.hide()
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

# NavButtons
func _on_room_pressed():
	pass # Replace with function body.

func _on_storage_pressed():
	pass # Replace with function body.

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)
	$AnimationPlayer.play("bump")

func _on_leave_pressed():
	SceneManager.change_scene("Map")
	
# SaveLoadButtons
func _on_save_pressed():
	pass # Replace with function body.

func _on_load_pressed():
	pass # Replace with function body.

func _on_back_pressed():
	$NavButtons.show()
	$SaveLoadButtons.hide()
	$StorageButtons.hide()
	$NavButtons/NavList/Button1.grab_focus()
	
func _on_store_pressed():
	pass # Replace with function body.

func _on_take_pressed():
	pass # Replace with function body.

func _weighted_rand(filter):
	var sortedDialogue = dialogue_tracker.values().filter(
		func filter(i):
			match filter:
				# show welcome and weather lines
				"welcome":
					if Global.currentDay <= 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or i.type in Global.weatherList or \
							(i.type == "regular" and oleanderFP >= 25) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.RIVER) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"talk":
					return i.type == "talk" or (i.type == "talk friend" and oleanderFP >= 25)
				# save / load / store / leave
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			return a.popularity < b.popularity
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	sortedDialogue[randInd].popularity += 1;
	print(sortedDialogue[randInd])
	return sortedDialogue[randInd].key;

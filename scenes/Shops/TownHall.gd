extends Node2D

const FRIEND_STATUS = 20
@onready var dialogue_tracker = $DialoguePlayer.dialogue_file.data

func _ready():
	var welcome_key = _weighted_rand("welcome")
	$ShopBox.show_dialogue($DialoguePlayer, welcome_key)
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$StorageMenu.menu_closed.connect(_on_menu_closed)
	
	$Menu/NavButtons.show()
	$Menu/SaveLoadButtons.hide()
	$Menu/StorageButtons.hide()
	$ConfirmPopup.hide()
	$LoadPopup.hide()
	$Menu/NavButtons/NavList/Button1.grab_focus()
	
	Global.FP.oleander += 1
	
func _on_dialogue_end():
	$Menu.show()
	$Menu/NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$Menu/NavButtons.show()

func _on_buy_pressed():
	$ShopBox.hide()
	$Menu/NavButtons.hide()
	$StorageMenu.show()

func _on_sell_pressed():
	$Menu/NavButtons.hide()
	$ShopBox.hide()
	$StorageMenu.show()

# NavButtons
func _on_room_pressed():
	$Menu/NavButtons.hide()
	$Menu/SaveLoadButtons.show()
	$Menu/SaveLoadButtons/NavList/Button1.grab_focus()
	$Menu/SaveLoadButtons/NavList/Button2.disabled = !FileAccess.file_exists("user://quingsterydungeon.save")

func _on_storage_pressed():
	$Menu/NavButtons.hide()
	$Menu/SaveLoadButtons.show()
	$Menu/SaveLoadButtons/NavList/Button1.grab_focus()

func _on_talk_pressed():
	var talk_key = _weighted_rand("talk")
	$ShopBox.show_dialogue($DialoguePlayer, talk_key)

func _on_leave_pressed():
	SceneManager.change_scene("Map")
	
# SaveLoadButtons
func _on_save_pressed():
	save_game()

func _after_save():
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.pressed.disconnect(_after_save)
	$Menu/SaveLoadButtons/NavList/Button2.disabled = !FileAccess.file_exists("user://quingsterydungeon.save")
	$ConfirmPopup.hide()
	$ShopBox.show()
	var dialogue_key = _weighted_rand("save")
	$ShopBox.show_dialogue($DialoguePlayer, dialogue_key)
	$Menu/SaveLoadButtons/NavList/Button1.grab_focus()

func _on_load_pressed():
	$ShopBox.hide()
	$LoadPopup/SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		"[center]Loading the file will overwrite existing data. Okay to continue?[/center]"
	$LoadPopup.show()
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.grab_focus()
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.connect(_after_no_load)
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.connect(load_game)
	
func _after_no_load():
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_after_no_load)
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(load_game)
	$LoadPopup.hide()
	$ShopBox.show()
	$Menu/SaveLoadButtons/NavList/Button2.grab_focus()
	
func _after_load():
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.pressed.disconnect(_after_load)
	$ConfirmPopup.hide()
	$ShopBox.show()
	var dialogue_key = _weighted_rand("load")
	$ShopBox.show_dialogue($DialoguePlayer, dialogue_key)
	$Menu/SaveLoadButtons/NavList/Button2.grab_focus()

func _on_back_pressed():
	$Menu/NavButtons.show()
	$Menu/SaveLoadButtons.hide()
	$Menu/StorageButtons.hide()
	$Menu/NavButtons/NavList/Button1.grab_focus()
	
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
					if Global.FP.oleander < 1:
						return i.type == "tutorial"
					else:
						return i.type == "welcome" or \
							(i.type in Global.weatherList and i.type == Global.currentWeather) or \
							(i.type == "regular" and Global.FP.oleander >= FRIEND_STATUS) or \
							(i.type == "Steps unlocked" and Global.currentCheckpoint >= Global.CheckpointType.STEPS) or \
							(i.type == "Peak unlocked" and Global.currentCheckpoint >= Global.CheckpointType.PEAK)
				"talk":
					return i.type == "talk" or (i.type == "talk friend" and Global.FP.oleander >= FRIEND_STATUS)
				# save / load / store / leave / liked gift / disliked gift / neutral gift
				_:
					return i.type == filter
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			var aPop = Global.dialogue_popularity.oleander[a.key] if a.key in Global.dialogue_popularity.oleander else 0
			var bPop = Global.dialogue_popularity.oleander[b.key] if b.key in Global.dialogue_popularity.oleander else 0
			return aPop < bPop
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	if sortedDialogue[randInd].key in Global.dialogue_popularity.oleander:
		Global.dialogue_popularity.oleander[sortedDialogue[randInd].key] += 1
	else:
		Global.dialogue_popularity.oleander[sortedDialogue[randInd].key] = 1
	return sortedDialogue[randInd].key;

func save_game():
	$ShopBox.hide()
	var save_file = FileAccess.open("user://quingsterydungeon.save", FileAccess.WRITE)
	var node_data = Global.save()
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)
	
	# after saving, show confirmation modal
	$ConfirmPopup/SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		"[center]...After taking a short rest, your progress has been saved![/center]"
	$ConfirmPopup.show()
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.grab_focus()
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.pressed.connect(_after_save)

func load_game():
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonLeft.pressed.disconnect(_after_no_load)
	$LoadPopup/SplitContainer/PopupBox/FooterMargin/ButtonRight.pressed.disconnect(load_game)
	if not FileAccess.file_exists("user://quingsterydungeon.save"):
		return # Error! We don't have a save to load.

	var save_file = FileAccess.open("user://quingsterydungeon.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		Global.load_data(node_data)
	
	# after loading, show confirmation modal
	$LoadPopup.hide()
	$ConfirmPopup/SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		"[center]Previous progress has been loaded![/center]"
	$ConfirmPopup.show()
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.grab_focus()
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.pressed.connect(_after_load)

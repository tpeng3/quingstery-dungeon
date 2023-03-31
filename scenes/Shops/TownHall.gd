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
	$AnimationPlayer.play("bump")
	$ShopBox.no_selected.connect(_on_dialogue_end)
	$BuyMenu.menu_closed.connect(_on_menu_closed)
	
	$Menu/NavButtons.show()
	$Menu/SaveLoadButtons.hide()
	$Menu/StorageButtons.hide()
	$ConfirmPopup.hide()
	$LoadPopup.hide()
	$Menu/NavButtons/NavList/Button1.grab_focus()
	
func _on_dialogue_end():
	$Menu.show()
	$Menu/NavButtons/NavList/Button3.grab_focus()
	
func _on_menu_closed(bought=false):
	var buy_key = _weighted_rand("buy")
	$ShopBox.show_dialogue($DialoguePlayer, buy_key)
	$AnimationPlayer.play("bump")
	$Menu/NavButtons.show()

func _on_buy_pressed():
	$ShopBox.hide()
	$Menu/NavButtons.hide()
	$BuyMenu.show()

func _on_sell_pressed():
	$Menu/NavButtons.hide()
	$ShopBox.hide()
	$BuyMenu.show()

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
	$AnimationPlayer.play("bump")

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
	$Menu/SaveLoadButtons/NavList/Button1.grab_focus()
	var dialogue_key = _weighted_rand("save")
	$ShopBox.show_dialogue($DialoguePlayer, dialogue_key)
	$AnimationPlayer.play("bump")

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
	$LoadPopup.hide()
	$ShopBox.show()
	$Menu/SaveLoadButtons/NavList/Button2.grab_focus()
	
func _after_load():
	$ConfirmPopup/SplitContainer/PopupBox/FooterMargin/ButtonMid.pressed.disconnect(_after_load)
	$ConfirmPopup.hide()
	$ShopBox.show()
	var dialogue_key = _weighted_rand("load")
	$ShopBox.show_dialogue($DialoguePlayer, dialogue_key)
	$AnimationPlayer.play("bump")
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

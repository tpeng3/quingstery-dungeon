extends Node2D

func _ready():
	$"VBoxContainer/Load Game".disabled = not FileAccess.file_exists("user://quingsterydungeon.save")

func _on_load_game_pressed():
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
		SceneManager.change_scene("Map")

func _on_quit_pressed():
	get_tree().quit()

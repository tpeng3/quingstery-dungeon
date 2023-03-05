#extends Node
#
## TODO: This is some ported code from Froggo's old project, we don't need all this
#enum ActionType { 
#	NONE,
#	BG,
#	SHOW_FOCUS,
#	HIDE,
#	CHOICES,
#	ANIMATION,
#	SOUND
#}
#enum PostActionType { NONE, MORE_TEXT, DELETE, UNLOCK }
#
#@export var dialogue_file: String # TODO: make sure it's a string .json file
#var dialogue_keys = []
#var postaction = null
#var current = 0
#var dialogue_name = ""
#var dialogue_expression = ""
#var dialogue_text = ""
#
#signal dialogue_started
#signal dialogue_action(action_type, asset)
#signal dialogue_finished(postaction_type, asset)
#
## load cutscene json script from the given file path
##func load_dialogue(file_path):
##	var file = File.new()
##	if file.file_exists(file_path):
##		file.open(file_path, file.READ)
##		var dialogue = parse_json(file.get_as_text())
##		return dialogue
#
## set dialogue lines to the dialogue keys
#func index_dialogue():
#	var dialogue = load_dialogue(dialogue_file)
#	dialogue_keys.clear()
#	for line in dialogue['lines']:
#		dialogue_keys.append(line)
#	if "post_action" in dialogue:
#		postaction = dialogue['post_action']
#
## called in Interface.gd when an event starts, updates dialogue screen values
#func start_dialogue():
#	emit_signal("dialogue_started")
#	current = 0
#	index_dialogue()
#	_set_dialogue()
#
## updates line count and continues the dialogue script
#func next_dialogue():
#	current += 1
#	# check for dialogue actions
#	if current < dialogue_keys.size():
#		_set_dialogue()
#	elif current == dialogue_keys.size():
#		_check_post_action()
#
#func _set_dialogue():
#	dialogue_name = ""
#	dialogue_expression = ""
#	dialogue_text = ""
#	for key in dialogue_keys[current]:
#		match key:
#			"name":
#				dialogue_name = dialogue_keys[current].name
#			"expression":
#				dialogue_expression = dialogue_keys[current].expression
#			"text":
#				dialogue_text = dialogue_keys[current].text
#			"action":
#				_check_action(dialogue_keys[current].action)
#			"multi_action":
#				for action in dialogue_keys[current]["multi_action"]:
#					_check_action(action)
#
#func _check_action(action):
#	var action_type = ActionType.NONE
#	var asset = null
#	if action[0] in ActionType:
#		action_type = ActionType[action[0]]
#		if len(action) == 2:
#			if action_type in [ActionType.BG, ActionType.SHOW_FOCUS, ActionType.SOUND]:
#				# TODO: i should do better typechecking but... lazy rn
#				var file = File.new()
#				print(action[1])
#				if file.file_exists(action[1]):
#					asset = load(action[1])
#					print(asset)
#			elif action_type == ActionType.ANIMATION:
#				asset = action[1]
#
#		emit_signal("dialogue_action", action_type, asset)
#
#func _check_post_action():
#	var postaction_type = PostActionType.NONE
#	var asset = null
#	if postaction and postaction[0] in PostActionType:
#		postaction_type = PostActionType[postaction[0]]
#		if len(postaction) == 2 \
#		and postaction_type == PostActionType.MORE_TEXT:
#			if postaction[1].get_extension() == "json":
#				asset = postaction[1]
#
#	emit_signal("dialogue_finished", postaction_type, asset)

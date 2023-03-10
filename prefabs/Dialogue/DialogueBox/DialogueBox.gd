extends CanvasLayer

var dialogue_node = null

signal yes_selected
signal no_selected

@onready var DialogueBox = $GUI/VSplitContainer/DialogueBox
@onready var DialogueName = $GUI/VSplitContainer/DialogueBox/NameContainer/Name
@onready var DialogueText = $GUI/VSplitContainer/DialogueBox/DialogueText
@onready var DialogueSelect = $GUI/VSplitContainer/UpperArea/UpperAreaDivider/DisplayArea/DialogueSelect

func _ready():
	hide()

func show_dialogue(dialogue):
	dialogue_node = dialogue
	show()
	if !dialogue_node.skipFade:
		$AnimationPlayer.play("textbox_fade")
	dialogue_node.dialogue_action.connect(_on_dialogue_action)
	dialogue_node.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_node.start_dialogue()
	_update_textbox()

func _input(event):
	# on enter/space or mouse click
	if self.visible and not DialogueSelect.visible and dialogue_node != null:\
		if event.is_action_pressed("ui_accept"):
#			DialogueSelect.ButtonHover.play()
			dialogue_node.next_dialogue()
			_update_textbox()

func _update_textbox():
	if dialogue_node.dialogue_name and dialogue_node.dialogue_name != "":
		DialogueName.text = dialogue_node.dialogue_name
		DialogueName.show()
#		if dialogue_node.dialogue_expression:
#			# TODO: make this more generic later, this is just old code
#			match dialogue_node.dialogue_name:
#				"???":
#					$Talksprites/Sprite2D.show()
#					$Talksprites/Sprite2D.change(dialogue_node.dialogue_expression)
#				"Bullfrog":
#					$Talksprites/Sprite2D.show()
#					$Talksprites/Sprite2D.change(dialogue_node.dialogue_expression)
	else:
		DialogueName.hide()
#		$Talksprites/Sprite2D.hide()
	DialogueText.text = dialogue_node.dialogue_text

func _on_dialogue_action(action_type, asset):
	match action_type:
		dialogue_node.ActionType.BG:
			change_bg(asset)
		dialogue_node.ActionType.SHOW_FOCUS:
			show_image(asset)
		dialogue_node.ActionType.HIDE:
			hide_image()
		dialogue_node.ActionType.CHOICES:
			DialogueSelect.show()
		dialogue_node.ActionType.ANIMATION:
			play_animation(asset)
		dialogue_node.ActionType.SOUND:
			play_sound(asset)

func _on_dialogue_finished(action_type = 0, asset = null):
#	self.hide_image()
#	$Talksprites/Sprite2D.hide()
	DialogueSelect.hide()
	$AnimationPlayer.play_backwards("textbox_fade")
	await $AnimationPlayer.animation_finished
	self.hide()
#	Input.set_custom_mouse_cursor(Utilities.CURSOR_DEFAULT)
	dialogue_node.dialogue_action.disconnect(_on_dialogue_action)
	dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
	match action_type:
		dialogue_node.PostActionType.MORE_TEXT:
			dialogue_node.dialogue_file = asset
#		dialogue_node.PostActionType.UNLOCK:
#			pass
#			# TODO: change this for quingstery later
		dialogue_node.PostActionType.DELETE:
			var to_delete = dialogue_node
			dialogue_node = null
			to_delete.get_parent().queue_free()
	emit_signal("no_selected")
	# OLD TODO: dunno if we want the above or to rework the logic hmmmmm

# TODO: sound check later
func _on_Button_mouse_entered():
#	Input.set_custom_mouse_cursor(Utilities.CURSOR_HOVER)
#	$Sounds/ButtonHover.play()
	pass

func _on_Button_mouse_exited():
#	Input.set_custom_mouse_cursor(Utilities.CURSOR_DEFAULT)
	pass
	
func _on_YesButton_button_up():
#	$ButtonClick.play()
	DialogueSelect.hide()
	emit_signal("yes_selected")

func show_image(image):
#	$Popup/Itemsprite.texture = image
	$Popup.show()

func hide_image():
	$Popup/Itemsprite.texture = null
	$Popup.hide()

# TODO: bg not be needed since we don't have lengthy vn cutscenes
func change_bg(image):
	if get_parent().name == "Memory":
		get_parent().change_bg(image)

func play_animation(asset):
	if get_parent().has_node("AnimationPlayer") and \
	asset in get_parent().get_node("AnimationPlayer").get_animation_list():
		get_parent().get_node("AnimationPlayer").play(asset)
		await $AnimationPlayer.animation_finished

func play_sound(asset):
	asset.set_loop(false)
	$Sounds/CustomSound.stream = asset
	$Sounds/CustomSound.play()

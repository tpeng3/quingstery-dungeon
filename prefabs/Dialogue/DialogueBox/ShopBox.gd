extends CanvasLayer

var dialogue_node = null
var freezeBox = false

signal yes_selected
signal no_selected

@onready var DialogueBox = $DialogueWrapper
@onready var DialogueName = $DialogueWrapper/NameContainer/Name
@onready var DialogueText = $DialogueWrapper/DialogueText
@onready var DialogueSelect = $DialogueWrapper/YesNo
var QuingeeIdle = load("res://assets/character/talksprites/quingee.png")
var QuingeeScraa = load("res://assets/character/talksprites/quingscraa.png")

func _ready():
	hide()
	
	$NewItemPopup.connect("on_confirm", _on_continue)
	
func enter_shop():
	$Quingee/Sprite2D/QuingAnim.play("QuingIn")
	$Control/Character/TalkSpriteAnim.play("CharIn")
	
func _reset_ui():
	show()
	$DialogueWrapper.hide()
	$NewItemPopup.hide()
	
func show_new_item(item, amount):
	# freeze character while there is dialogue
	Global.freezeQuingee = true
	await get_tree().create_timer(.1).timeout
	
	_reset_ui()
	$NewItemPopup.show_item(item, amount)
	Inventory.add_item(item, amount)

func show_dialogue(dialogue, dictKey=null):
	if dictKey and dictKey != "welcome":
		$AnimationPlayer.play("bump")
	# freeze character while there is dialogue
	Global.freezeQuingee = true
	freezeBox = false
	
	dialogue_node = dialogue
	_reset_ui()
	$DialogueWrapper.show()
	if not dialogue_node.dialogue_action.is_connected(_on_dialogue_action):
		dialogue_node.dialogue_action.connect(_on_dialogue_action)
	if not dialogue_node.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue_node.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_node.start_dialogue(dictKey)
	_update_textbox()

func _input(event):
	# on enter/space or mouse click
	if self.visible and not DialogueSelect.visible and dialogue_node != null and not freezeBox:
		if event.is_action_released("ui_accept"):
#			DialogueSelect.ButtonHover.play()
			dialogue_node.next_dialogue()
			if dialogue_node:
				_update_textbox()
	
	# scraaa
	if event.is_action_pressed("scraa"):
		$Quingee/Sprite2D.texture = QuingeeScraa
		$Quingee/Sprite2D/QuingAnim.play("QuingShake")
		await $Quingee/Sprite2D/QuingAnim.animation_finished
		$Quingee/Sprite2D.texture = QuingeeIdle

func _on_continue():
	# TODO: clean this up later
	_on_dialogue_finished()

func _update_textbox():
	if dialogue_node.dialogue_name and dialogue_node.dialogue_name != "":
		DialogueName.text = dialogue_node.dialogue_name
		DialogueName.show()
		$DialogueWrapper/ClickToContinue.visible = true
#		if dialogue_node.dialogue_expression:
#			# TODO: make this more generic later, this is just old code
#			match dialogue_node.dialogue_name:
#				"???":
#					$Talksprites/Sprite2D.show()
#					$Talksprites/Sprite2D.change(dialogue_node.dialogue_expression)
#				"Bullfrog":
#					$Talksprites/Sprite2D.show()
#					$Talksprites/Sprite2D.change(dialogue_node.dialogue_expression)
		if freezeBox:
			$DialogueWrapper/ClickToContinue.visible = false
	else:
		DialogueName.hide()
#		$Talksprites/Sprite2D.hide()
	DialogueText.text = dialogue_node.dialogue_text

func _on_dialogue_action(action_type, asset):
	match action_type:
		dialogue_node.ActionType.BG:
			change_bg(asset)
		dialogue_node.ActionType.GET_ITEM:
			show_image(asset)
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
		dialogue_node.ActionType.FREEZE:
			emit_signal("no_selected")
			Global.freezeQuingee = false
			freezeBox = true

func _on_dialogue_finished(action_type = 0, asset = null, amount = 1):
#	self.hide_image()
#	$Talksprites/Sprite2D.hide()
	DialogueSelect.hide()
	self.hide()
	
#	Input.set_custom_mouse_cursor(Utilities.CURSOR_DEFAULT)
	if dialogue_node:
		dialogue_node.dialogue_action.disconnect(_on_dialogue_action)
		dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
		print("on dialogue finished?", action_type)
		match action_type:
			dialogue_node.PostActionType.MORE_TEXT:
				dialogue_node.dialogue_file = asset
	#		dialogue_node.PostActionType.UNLOCK:
	#			pass
	#			# TODO: change this for quingstery later
			dialogue_node.PostActionType.DELETE:
				var to_delete = dialogue_node
				to_delete.get_parent().queue_free()
			dialogue_node.PostActionType.GIVE:
				print("give here?", asset, amount)
				show_new_item(asset, amount)
				dialogue_node = null
				return
		dialogue_node = null
				
	emit_signal("no_selected")
	# OLD TODO: dunno if we want the above or to rework the logic hmmmmm
	
	# quingee can move again
	await get_tree().create_timer(.1).timeout
	Global.freezeQuingee = false

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

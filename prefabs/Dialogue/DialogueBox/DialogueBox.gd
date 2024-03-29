extends CanvasLayer

var dialogue_node = null
var freezeBox = false

signal yes_selected(type)
signal no_selected

@onready var DialogueBox = $DialogueWrapper
@onready var DialogueName = $DialogueWrapper/NameContainer/Name
@onready var DialogueText = $DialogueWrapper/DialogueText
@onready var DialogueSelect = $DialogueWrapper/YesNo

func _ready():
	hide()
	$NewItemPopup.connect("on_confirm", _on_continue)
	
func _reset_ui():
	show()
	DialogueSelect.hide()
	DialogueBox.hide()
	$NewItemPopup.hide()
	if $AmountPopup:
		$AmountPopup.hide()
	
func show_new_item(item, amount, text=null):
	# freeze character while there is dialogue
	Global.freezeQuingee = true
	await get_tree().create_timer(.1).timeout
	
	_reset_ui()
	$NewItemPopup.show_item(item, amount, text)
	Inventory.add_item(item, amount)

func show_dialogue(dialogue, dictKey=null):
	# freeze character while there is dialogue
	Global.freezeQuingee = true
	freezeBox = false
	
	dialogue_node = dialogue
	_reset_ui()
	$DialogueWrapper.show()
	if !dialogue_node.skipFade:
		$AnimationPlayer.play("textbox_fade")
	if not dialogue_node.dialogue_action.is_connected(_on_dialogue_action):
		dialogue_node.dialogue_action.connect(_on_dialogue_action)
	if not dialogue_node.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue_node.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_node.start_dialogue(dictKey)
	_update_textbox()

func _on_dialogue_box_input(event):
	# on enter/space or mouse click
	if dialogue_node != null and not freezeBox and event.is_action_released("ui_accept"):
#			DialogueSelect.ButtonHover.play()
		dialogue_node.next_dialogue()
		if dialogue_node:
			_update_textbox()

func _on_continue():
	# TODO: clean this up later
	_on_dialogue_finished()

func _update_textbox():
	if dialogue_node.dialogue_name and dialogue_node.dialogue_name != "":
		DialogueName.text = dialogue_node.dialogue_name
		DialogueName.show()
	else:
		DialogueName.hide()
	DialogueText.text = dialogue_node.dialogue_text
	if freezeBox or DialogueSelect.visible:
		$DialogueWrapper/ClickToContinue.visible = false
	else:
		$DialogueWrapper/ClickToContinue.visible = true
		await get_tree().create_timer(.1).timeout
		$DialogueWrapper/ClickToContinue/ArrowBtn.grab_focus()

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
			DialogueSelect.show_yesno()
			$DialogueWrapper/ClickToContinue.visible = false
		dialogue_node.ActionType.ANIMATION:
			play_animation(asset)
		dialogue_node.ActionType.SOUND:
			play_sound(asset)
		dialogue_node.ActionType.FREEZE:
			emit_signal("no_selected")
			Global.freezeQuingee = false
			freezeBox = true

func _on_dialogue_finished(action_type = 0, asset = null, amount = 1):
	DialogueSelect.hide()
#	$AnimationPlayer.play_backwards("textbox_fade")
#	await $AnimationPlayer.animation_finished
	self.hide()
	
	if dialogue_node:
		dialogue_node.dialogue_action.disconnect(_on_dialogue_action)
		dialogue_node.dialogue_finished.disconnect(_on_dialogue_finished)
		match action_type:
			dialogue_node.PostActionType.MORE_TEXT:
				dialogue_node.dialogue_file = asset
			dialogue_node.PostActionType.DELETE:
				var to_delete = dialogue_node
				to_delete.get_parent().queue_free()
			dialogue_node.PostActionType.GIVE:
				show_new_item(asset, amount)
				dialogue_node = null
				return
		dialogue_node = null
				
	no_selected.emit()
	
	# clear existing yes/no signals
	var signals = get_signal_list();
	for cur_signal in signals:
		var conns = get_signal_connection_list(cur_signal.name);
		for cur_conn in conns:
			cur_conn['signal'].disconnect(cur_conn['callable'])
	
	# quingee can move again
	await get_tree().create_timer(.1).timeout
	Global.freezeQuingee = false
	
func _on_dialogue_yes_pressed():
#	$ButtonClick.play()
	DialogueBox.hide()
	DialogueSelect.hide()
	yes_selected.emit()

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

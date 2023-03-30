extends Node2D

var last_focused = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# listen for button focuses
	for i in $Control/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
		
	for i in $TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
		
	$DialogueBox.no_selected.connect(_on_npc_finished)
	$DialogueBox/NewItemPopup.on_confirm.connect(_on_npc_finished)
	
	$"Control/VBoxContainer/Town Hall".grab_focus()
	$TownPanel.hide()
	
	Global.newDay()
	# generate the random NPC spots
	var Spots = $TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer
	for n in 3:
		_add_npc(Global.npcData[n], Spots.get_node("Spot" + str(n + 1)))
	
func _add_npc(npc, node):
	node.text = npc.location
	node.npc = npc
	node.disabled = npc.visited
	node.on_dialogue.connect(_on_npc_dialogue)
	
func _on_npc_dialogue(node):
	last_focused = node
	node.npc.visited = true
	node.npc.popularity += 1
	node.disabled = true
	$TownPanel.hide()
	$RightPanel.hide()
	$DialogueBox.show_dialogue($DialoguePlayer, node.npc.key)

func update_panel(node):
	$RightPanel/MarginContainer/TitleMargin/MapName.text = node.text
	# find map bip
	if $SubViewportContainer/SubViewport/MapButtons.has_node(str(node.text)):
		$RightPanel.show()
		var bip = $SubViewportContainer/SubViewport/MapButtons.get_node(str(node.text))
		bip.enter_focus()
		if node.disabled:
			$RightPanel/MarginContainer/DescPadding/FlowContainer/MapDesc.text = "No one seems to be around here anymore."
		else:
			$RightPanel/MarginContainer/DescPadding/FlowContainer/MapDesc.text = bip.mapDesc
	else:
		$RightPanel.hide()
		$SubViewportContainer/SubViewport/Camera2D.focused_location = null
		$SubViewportContainer/SubViewport/Camera2D.position = Vector2(0, 0)

func exit_panel(node):
	if $SubViewportContainer/SubViewport/MapButtons.has_node(str(node.text)):
		var bip = $SubViewportContainer/SubViewport/MapButtons.get_node(str(node.text))
		bip.exit_focus()

func _on_explore_town_pressed():
	$Control.hide()
	$TownPanel.show()
	$"TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer/Trading Post".grab_focus()

func _on_navi_close_pressed():
	$TownPanel.hide()
	$Control.show()
	$"Control/VBoxContainer/Explore Town".grab_focus()

func _on_npc_finished():
	$TownPanel.show()
	$RightPanel.show()
	last_focused.grab_focus()


func _on_navi_close_focus_entered():
	$RightPanel.hide()

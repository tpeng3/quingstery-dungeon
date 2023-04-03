extends Node2D

var last_focused = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Control/VBoxContainer/Town Hall".grab_focus()
	$TownPanel.hide()
	
	# generate the random NPC spots
	var Spots = $TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer
	for n in 3:
		_add_npc(Global.npcData[n], Spots.get_node("Spot" + str(n + 1)))
	
	# listen for button focuses
	for i in $Control/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
		
		if Global.last_town_menu_button and Global.last_town_menu_button == i.get_path():
			i.grab_focus()
		
	for i in $TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
		
		if Global.last_town_menu_button and Global.last_town_menu_button == i.get_path():
			_on_explore_town_pressed()
			i.grab_focus()
		
	$DialogueBox.no_selected.connect(_on_npc_finished)
	$DialogueBox/NewItemPopup.on_confirm.connect(_on_npc_finished)
		
	$SubViewportContainer/SubViewport/WeatherFilter.show_weather()
	$SubViewportContainer/SubViewport/WeatherFilter.update_rect($"Control/VBoxContainer/Town Hall".position)
	
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
		$SubViewportContainer/SubViewport/WeatherFilter.update_rect(bip.position)
	else:
		$RightPanel.hide()
		$SubViewportContainer/SubViewport/Camera2D.focused_location = null
		$SubViewportContainer/SubViewport/Camera2D.position = Vector2(0, 0)
		$SubViewportContainer/SubViewport/WeatherFilter.update_rect(Vector2(0, 0))

func exit_panel(node):
	if $SubViewportContainer/SubViewport/MapButtons.has_node(str(node.text)):
		var bip = $SubViewportContainer/SubViewport/MapButtons.get_node(str(node.text))
		bip.exit_focus()

func _on_explore_town_pressed():
	$Control.hide()
	$TownPanel.show()
	$"TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer/Trading Post".grab_focus()
	last_focused = $"Control/VBoxContainer/Explore Town"

func _on_navi_close_pressed():
	$MountainInfo.hide()
	$TownPanel.hide()
	$Control.show()
	last_focused.grab_focus()

func _on_npc_finished():
	$TownPanel.show()
	$RightPanel.show()
	last_focused.grab_focus()

func _on_navi_close_focus_entered():
	$RightPanel.hide()

func _on_climb_peak_pressed():
	last_focused = $"Control/VBoxContainer/Climb Peak"
	$Control.hide()
	$MountainInfo.show()
	$MountainInfo/OuterPadding/BoxContainer/LeftSide/Mountain/Sections/Throat.grab_focus()

func _on_go_button_pressed():
	# TODO: TEMPORARY WHILE MOUNTAIN IS STILL IN THE WORKS
	Global.newDay()
	SceneManager.change_scene("Map")

extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# listen for button focuses
	for i in $Control/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
		
	for i in $TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer.get_children():
		i.on_focus.connect(update_panel)
		i.on_exit.connect(exit_panel)
	
	$"Control/VBoxContainer/Town Hall".grab_focus()
	$TownPanel.hide()
	
	# TODO: generate the random NPC spots
	
	# TODO: call this only when quingee returns from mountain (move elsewhere later)
	Global.newDay()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_panel(node):
	$RightPanel/MarginContainer/TitleMargin/MapName.text = node.name
	# find map bip
	if $SubViewportContainer/SubViewport/MapButtons.has_node(str(node.name)):
		var bip = $SubViewportContainer/SubViewport/MapButtons.get_node(str(node.name))
		bip.enter_focus()
		$RightPanel/MarginContainer/DescPadding/FlowContainer/MapDesc.text = bip.mapDesc
	else:
		$SubViewportContainer/SubViewport/Camera2D.focused_location = null
		$SubViewportContainer/SubViewport/Camera2D.position = Vector2(0, 0)

func exit_panel(node):
	if $SubViewportContainer/SubViewport/MapButtons.has_node(str(node.name)):
		var bip = $SubViewportContainer/SubViewport/MapButtons.get_node(str(node.name))
		bip.exit_focus()

func _on_explore_town_pressed():
	$Control.hide()
	$TownPanel.show()
	$"TownPanel/SplitContainer/LeftPanel/PanelPadding/VBoxContainer/Trading Post".grab_focus()

func _on_navi_close_pressed():
	$TownPanel.hide()
	$Control.show()
	$"Control/VBoxContainer/Explore Town".grab_focus()

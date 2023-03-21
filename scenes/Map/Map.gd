extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var MapButtons = $"SubViewportContainer/SubViewport/MapButtons"
	MapButtons.get_child(0).grab_focus()
	update_panel(MapButtons.get_child(0))
	
	for i in MapButtons.get_children():
		i.map_focused.connect(update_panel)
	
	Global.newDay()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_panel(node):
	$RightPanel/MarginContainer/TitleMargin/MapName.text = node.name
	$RightPanel/MarginContainer/DescPadding/FlowContainer/MapDesc.text = node.mapDesc

extends ItemList
var throat
var river
var steps
var peak
var items = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("res://assets/items.json", FileAccess.READ);
	items = JSON.parse_string(file.get_as_text())
	
	throat = getSection(items, 'Throat')
	river = getSection(items, "River")
	steps = getSection(items, 'Steps')
	peak = getSection(items, 'Steps')
	
	$"../../../../../LeftSide/Mountain/Sections/River".disabled = Global.currentCheckpoint < Global.CheckpointType.RIVER
	$"../../../../../LeftSide/Mountain/Sections/Steps".disabled = Global.currentCheckpoint < Global.CheckpointType.STEPS
	$"../../../../../LeftSide/Mountain/Sections/Peak".disabled = Global.currentCheckpoint < Global.CheckpointType.PEAK

func getSection(items, section):
	return items.filter(func(val): return (section in val.source || "Mountain (global)" in val.source))

func _on_throat_focus_entered():
	self.clear()
	$"../RichTextLabel".visible = false
	$"../../../../../../FooterMargin/GoButton".disabled = false
	if Global.currentCheckpoint >= Global.CheckpointType.THROAT:
		for i in throat:
			self.add_icon_item(load(i.path))

func _on_river_focus_entered():
	self.clear()
	$"../RichTextLabel".visible = Global.currentCheckpoint < Global.CheckpointType.RIVER
	if Global.currentCheckpoint >= Global.CheckpointType.RIVER:
		for i in river:
			self.add_icon_item(load(i.path))
		$"../../../../../../FooterMargin/GoButton".disabled = false
	else:
		$"../../../../../../FooterMargin/GoButton".disabled = true

func _on_steps_focus_entered():
	self.clear()
	$"../RichTextLabel".visible = Global.currentCheckpoint < Global.CheckpointType.STEPS
	if Global.currentCheckpoint >= Global.CheckpointType.STEPS:
		for i in steps:
			self.add_icon_item(load(i.path))
		$"../../../../../../FooterMargin/GoButton".disabled = false
	else:
		$"../../../../../../FooterMargin/GoButton".disabled = true

func _on_peak_focus_entered():
	self.clear()
	$"../RichTextLabel".visible = Global.currentCheckpoint < Global.CheckpointType.PEAK
	if Global.currentCheckpoint >= Global.CheckpointType.PEAK:
		for i in peak:
			self.add_icon_item(load(i.path))
		$"../../../../../../FooterMargin/GoButton".disabled = false
	else:
		$"../../../../../../FooterMargin/GoButton".disabled = true

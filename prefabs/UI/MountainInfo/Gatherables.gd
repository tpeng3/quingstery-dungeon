extends ItemList
var throat
var river
var steps
var peak


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("res://assets/items.json", FileAccess.READ);	
	var items = JSON.parse_string(file.get_as_text())
	
	throat = getSection(items, 'Throat')
	river = getSection(items, "River")
	steps = getSection(items, 'Steps')
	peak = getSection(items, 'Steps')
	
	pass # Replace with function body.

func getSection(items, section):
	return items.filter(func(val): return (section in val.Source || "Mountain (global)" in val.Source))

func _on_throat_focus_entered():
	$"../../../../../LeftSide/Mountain/Sections/Throat".emit_signal("pressed")
	pass # Replace with function body.


func _on_river_focus_entered():
	$"../../../../../LeftSide/Mountain/Sections/River".emit_signal("pressed")
	pass # Replace with function body.


func _on_steps_focus_entered():
	$"../../../../../LeftSide/Mountain/Sections/Steps".emit_signal("pressed")
	pass # Replace with function body.


func _on_peak_focus_entered():
	$"../../../../../LeftSide/Mountain/Sections/Peak".emit_signal("pressed")
	pass # Replace with function body.

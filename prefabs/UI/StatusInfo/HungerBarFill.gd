extends TextureRect
var meter_gradient = Gradient.new();

# Called when the node enters the scene tree for the first time.
func _ready():
	# sets up gradient w/ desired interpolation + default points
	meter_gradient.interpolation_mode = 0
	meter_gradient.add_point(0, Color.INDIAN_RED)
	meter_gradient.add_point(0.5, Color.WHITE)
	pass # Replace with function body.

func _process(_delta):
	var hunger_curr = $"/root/Global".currentHunger;
	var hunger_max = $"/root/Global".maxHunger;
	
	# Changes position of gradient to hunger %
	self.texture.gradient.offsets[1] = float(hunger_curr)/hunger_max

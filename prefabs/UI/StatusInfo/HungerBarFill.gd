extends TextureRect
var meter_gradient = Gradient.new();


@onready var box = get_node("HungerBarFill")

# Called when the node enters the scene tree for the first time.
func _ready():
	# sets up gradient w/ desired interpolation + default points
	meter_gradient.InterpolationMode = 0
	meter_gradient.add_point(0, Color.INDIAN_RED)
	meter_gradient.add_point(0.5, Color.WHITE)
	pass # Replace with function body.

func _process(_delta):
	var hunger_curr = box.get_meta("Hunger_Curr");
	var hunger_max = box.get_meta("Hunger_Max");
	
	# Changes position of gradient to hunger %
	meter_gradient.set_offset(1, float(hunger_curr)/hunger_max)
	
	# makes gradienttexture so that it can replace existing gradienttexture
	var gradient_texture := GradientTexture2D.new() 
	gradient_texture.gradient = meter_gradient
	
	box.texture = gradient_texture # sets new texture I fucking hope
	
	pass

extends Control

@onready var Inventory = get_node("/root/Inventory")

func _ready():
	show()

# Called when the node enters the scene tree for the first time.
func _process(delta):
	$UpperInfo/HSplitContainer/GaldCounter/FlowContainer/GaldLabel.text = \
		str(Inventory.gald) + "  "
	$UpperInfo/HSplitContainer/InventoryAmt/FlowContainer/InventoryLabel.text = \
		str(Inventory.get_inv_count()) + "/" + str(Inventory.max) + "   "

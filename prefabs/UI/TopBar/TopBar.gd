extends Control

@onready var Inventory = get_node("/root/Inventory")

# Called when the node enters the scene tree for the first time.
func _process(delta):
	$UpperInfo/HSplitContainer/GaldCounter/GaldLabel.text = \
		str(Inventory.gald) + " Gald"
	$UpperInfo/HSplitContainer/InventoryAmt/InventoryLabel.text = \
		str(Inventory.get_inv_count()) + "/" + str(Inventory.max)

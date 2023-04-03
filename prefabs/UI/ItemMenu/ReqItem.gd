extends MarginContainer

func show_req(req):
	var has_req = req.item in Inventory.inventory and Inventory.inventory[req.item].count >= req.amount
	$SplitContainer/MarginContainer/Sprite2D.region_rect = Rect2(10, 0, 10, 10) if has_req else Rect2(0, 0, 10, 10)
	$SplitContainer/Name.text = req.item
	$SplitContainer/Amount.text = "x" + str(req.amount)
	show()

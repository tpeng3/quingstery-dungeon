extends MarginContainer

func show_req(req):
	var inv_count = Inventory.inventory[req.item].count if req.item in Inventory.inventory else 0
	var storage_count = Inventory.storage[req.item].count if req.item in Inventory.storage else 0
	var has_req = inv_count + storage_count >= req.amount
	$SplitContainer/MarginContainer/Sprite2D.region_rect = Rect2(10, 0, 10, 10) if has_req else Rect2(0, 0, 10, 10)
	$SplitContainer/Name.text = req.item
	$SplitContainer/Amount.text = "x" + str(req.amount) + " (" + str(inv_count + storage_count) + ")"
	show()

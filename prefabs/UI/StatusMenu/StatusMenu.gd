extends Control


# Called when the node enters the scene tree for the first time.
func show_screen():
	update_screen()
	show()

func update_screen():
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Hunger/HungerBar.max_value = Global.maxHunger
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Hunger/HungerBar.value = Global.currentHunger
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Hunger/HungerLabel/HungerAmt.text = \
		str(Global.currentHunger) + "/" + str(Global.maxHunger) + " full"
		
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Inventory/InventoryBar.max_value = Inventory.max
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Inventory/InventoryBar.value = Inventory.get_inv_count()
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Inventory/InventoryLabel/InventoryAmt.text = \
		str(Inventory.get_inv_count()) + "/" + str(Inventory.max) + " space"

	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Quests/QuestsAmt.text = \
		str(Quest.quests.keys().size() - Quest.get_completed_count()) + " active"
	if Quest.get_completed_count() > 0:
		$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/Quests/QuestsAmt.text += \
			", " + str(Quest.get_completed_count()) + " completed"

	# equipment
	if Inventory.equipped.size() > 0:
		var clothing = Inventory.equipped[0]
		$OuterPadding/MainContentPadding/BoxContainer/Dressup/Quingee/Equip.texture = \
			load("res://assets/character/statusmenu/" + clothing.replace(" ", "") + ".png")
	else:
		$OuterPadding/MainContentPadding/BoxContainer/Dressup/Quingee/Equip.texture = null
	
	var equipStr = ""
	for n in 3:
		if n <= Inventory.equipped.size() - 1:
			var equip = $OuterPadding/MainContentPadding/BoxContainer/StatDisplay/BoxContainer.find_child("Equip" + str(n + 1)).find_child("Sprite2D")
			var item = Inventory.find_item(Inventory.equipped[n])
			equip.texture = load(item.path)
			equipStr += \
				Inventory.find_item(Inventory.equipped[n]).description + "\n"
				
	$OuterPadding/MainContentPadding/BoxContainer/StatDisplay/RichTextLabel.text = \
		equipStr if equipStr else "No items equipped."
		
	$OuterPadding/MainContentPadding/BoxContainer/ClimbDisplay.update_progress()
	

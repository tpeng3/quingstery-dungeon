extends MarginContainer

class_name ListItem

@export var item_name:String = "Acorn"
@export var item_type:String = "Buy"
@export var item_amount:int = 1
@export var item_cost:int = -1
@export var item_trade = []
var item_texture:Texture2D

signal on_focus

func _ready():
	item_texture = load(Inventory.find_item(item_name).path)
	$FlowContainer/SpriteBox/ItemSprite.texture = item_texture
	update_item()

func update_item():
	var amount_str = " x" + str(item_amount) if item_amount > 1 else ""
	$FlowContainer/ItemName.text = "[b]" + item_name + "[/b]" + amount_str
	if item_cost <= -99:
		$FlowContainer/RightAlign/ItemInfo.text = ""
		$FlowContainer/RightAlign/GaldSymbol.hide()
		$FlowContainer/RightAlign/EquipSymbol.hide()
		var equip_index = Inventory.equipped.find(item_name, 0)
		if item_type == "Equip" and equip_index > 0:
			$FlowContainer/RightAlign/EquipSymbol.show() 
			$FlowContainer/RightAlign/EquipSymbol/Sprite2D.region.x = equip_index * 10
	elif (item_type == "Equip" or item_type == "Upgrade") and item_name in Inventory.inventory:
		$FlowContainer/RightAlign/ItemInfo.text = "SOLD"
		$FlowContainer/RightAlign/GaldSymbol.hide()
	elif item_trade:
		$FlowContainer/RightAlign/ItemInfo.text = "TRADE"
		$FlowContainer/RightAlign/GaldSymbol.hide()
	elif item_cost > 0:
		$FlowContainer/RightAlign/ItemInfo.text = str(item_cost)
		$FlowContainer/RightAlign/GaldSymbol.show()
	else:
		$FlowContainer/RightAlign.visible = false

func _on_focus_entered():
	$Panel.theme_type_variation = "Panel_Highlight"
	on_focus.emit(self)

func _on_focus_exited():
	$Panel.theme_type_variation = ""

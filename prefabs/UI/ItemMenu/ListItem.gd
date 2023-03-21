extends MarginContainer

@export var item_name:String = "Acorn"
@export var item_info:String
var item_texture:Texture2D

func _ready():
	print(item_name, item_info)
	item_texture = load(Inventory.find_item(item_name).path)
	$FlowContainer/SpriteBox/ItemSprite.texture = item_texture
	$FlowContainer/ItemName.text = item_name
	if item_info:
		$FlowContainer/RightAlign/ItemInfo.text = item_info
	else:
		$FlowContainer/RightAlign.visible = false

func update_item():
	# TODO: if an item gets sold or traded or out of stock
	pass

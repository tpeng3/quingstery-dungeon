extends MarginContainer

@export var item_name:String = "Acorn"
@export var item_amount:int = 1
@export var item_info:String
var item_texture:Texture2D

func _ready():
	item_texture = load(Inventory.find_item(item_name).path)
	$FlowContainer/SpriteBox/ItemSprite.texture = item_texture
	var amount_str = " x" + str(item_amount) if item_amount > 1 else ""
	$FlowContainer/ItemName.text = "[b]" + item_name + "[/b]" + amount_str
	if item_info:
		$FlowContainer/RightAlign/ItemInfo.text = item_info
	else:
		$FlowContainer/RightAlign.visible = false

func update_item():
	# TODO: if an item gets sold or traded or out of stock
	pass


func _on_focus_entered():
	print("i dare you to focus")
	$Panel.theme_type_variation = "Panel_Highlight"

func _on_focus_exited():
	$Panel.theme_type_variation = ""

@tool
extends Control

@export_multiline var item_desc:String = "How many [b][item][/b] do you want to sell? (Owned: [amount])"
@export var item_name:String = "Acorn"
@export var item_max:int = 10
@export var item_current:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var item_dict = Inventory.find_item(item_name)
	var item_texture = load(item_dict.path)
	$SplitContainer/ItemMargin/ItemSprite.texture = item_texture
	$SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		item_desc.replace("[item]", item_name).replace("[amount]", str(item_max))
		
		
	$OuterPadding/SplitContainer/RightPanel/MarginContainer/DescPadding/FlowContainer/ItemDesc.text = item_dict.description

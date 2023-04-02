extends Control

@export_multiline var item_desc:String = "How many [b][item][/b] do you want to sell?"
@export var item_name:String = "Acorn"
@export var item_cost = 0

func _ready():
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount_update.connect(_on_update)

# Called when the node enters the scene tree for the first time.
func show_popup(node: ListItem):
	item_name = node.item_name
	item_cost = node.item_cost
	var item_dict = Inventory.find_item(item_name)
	var item_texture = load(item_dict.path)
	$SplitContainer/ItemMargin/ItemSprite.texture = item_texture
	$SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		item_desc.replace("[item]", item_name)
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount_max = node.item_amount
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount = node.item_amount
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.update_arrows()
	show()

func _on_update(amount):
	$SplitContainer/PopupBox/FooterMargin/ButtonRight.text = "sell (₲" + str(amount * item_cost) + ")"
	$SplitContainer/PopupBox/FooterMargin/ButtonRight.disabled = amount <= 0

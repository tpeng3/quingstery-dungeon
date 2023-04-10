extends Control

@export_multiline var item_desc:String = "How many [b][item][/b] do you want to sell?"
@export var item_name:String = "Acorn"
@export var item_cost = 0
enum PopupType {
	STORE,
	TAKE,
	SELL,
	TRADE
}
@export var popup_type:PopupType = PopupType.SELL

func _ready():
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount_update.connect(_on_update)

func show_popup(node: ListItem, max_amount=0):
	item_name = node.item_name
	if popup_type != PopupType.TRADE:
		item_cost = node.item_cost
	var item_dict = Inventory.find_item(item_name)
	var item_texture = load(item_dict.path)
	var item_max = max_amount if max_amount > 0 else node.item_amount
	$SplitContainer/ItemMargin/ItemSprite.texture = item_texture
	$SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		item_desc.replace("[item]", item_name).replace("[max]", str(item_max))
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount_max = item_max
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount = item_max
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.update_arrows()
	if popup_type == PopupType.STORE:
		$SplitContainer/PopupBox/FooterMargin/ButtonRight.text = "store"
	elif popup_type == PopupType.TAKE:
		$SplitContainer/PopupBox/FooterMargin/ButtonRight.text = "take"
	show()
	$SplitContainer/PopupBox/SplitContainer/AmountSelect/SplitContainer/MiddleRow/NumberDisplay.grab_focus()
	
func show_trade_popup(request, request_max, reward, reward_num):
	item_name = request
	var item_dict = Inventory.find_item(item_name)
	var item_texture = load(item_dict.path)
	$SplitContainer/ItemMargin/ItemSprite.texture = item_texture
	$SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText.text = \
		item_desc.replace("[item]", item_name).replace("[max]", str(request_max))
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount_max = request_max
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.amount = request_max
	$SplitContainer/PopupBox/SplitContainer/AmountSelect.update_arrows()
	$SplitContainer/PopupBox/FooterMargin/ButtonRight.text = "trade"
	show()
	$SplitContainer/PopupBox/SplitContainer/AmountSelect/SplitContainer/MiddleRow/NumberDisplay.grab_focus()

func _on_update(amount):
	if popup_type == PopupType.SELL:
		$SplitContainer/PopupBox/FooterMargin/ButtonRight.text = "sell (₲" + str(amount * item_cost) + ")"
	$SplitContainer/PopupBox/FooterMargin/ButtonRight.disabled = amount <= 0

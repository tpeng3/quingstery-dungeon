extends Control

@export_multiline var default_text: String = "[center]You received [b]x[amount] [item][/b]! It's been tucked into your inventory.
[/center]"

@onready var PopupText = $SplitContainer/PopupBox/SplitContainer/TextPadding/PopupText

signal on_confirm

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	PopupText.text = default_text

func _on_confirm():
	hide()
	emit_signal("on_confirm")

func show_item(item, amount, popup_text):
	var sprite = $"/root/Inventory".find_item(item)
	assert (sprite, "Failed to find sprite for " + item)
	
	var desc_text = popup_text if popup_text != null else default_text
	$SplitContainer/ItemMargin/ItemSprite.texture = load(sprite.path)
	PopupText.text = desc_text.replace("[amount]", str(amount)).replace("[item]", item)
	show()
	$SplitContainer/PopupBox/FooterMargin/ButtonMid.grab_focus()

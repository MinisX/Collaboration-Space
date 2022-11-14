extends Node

#onready var grinningEmoji_button:TextureButton = $Panel/grinningEmoji


export (String) var current_emoji : String = "SomeEmojiName"
var emoji_group: ButtonGroup = null
onready var emojis_ok_button:Button = $Panel/OkButton
var emojis_UI_visibility: bool = true

signal emoji_pressed(which)
#var emoji_is_shown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_group = $Panel/One.group
	emoji_group.connect("pressed", self, "_on_emoji_selected")
	emoji_group.connect("pressed", self, "_on_emoji_selected")
	emojis_ok_button.connect("pressed", self, "_on_emoji_ok_button_pressed")
	#grinningEmoji_button.connect("pressed", self, "_on_grinningEmoji_button_pressed")
	#$Panel/grinningEmoji.connect("emoji_sent", get_parent(), "_get_emoji")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_emoji_selected(pressed: TextureButton) -> void:
	#$"../TextureRect".show()
	print("Emoji button is pressed")
	#$"../TextureRect/Timer".start()
	emit_signal("emoji_pressed", pressed.name)

func _on_emoji_ok_button_pressed() -> void:
	if emojis_UI_visibility == false:
		$".".show()
		#$"../EmojisButton".hide()
		emojis_UI_visibility = true
	else:
		$".".hide()
		#$"../EmojisButton".show()
		emojis_UI_visibility = false

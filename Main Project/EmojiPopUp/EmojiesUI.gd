extends Node


export (String) var current_emoji : String = "SomeEmojiName"
var emoji_group: ButtonGroup = null
onready var emojis_dnd_button:Button = $Panel/Seventeen

var emojis_UI_visibility: bool = true
var dnd_on: bool = false

signal emoji_pressed(which)


# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_group = $Panel/One.group
	emoji_group.connect("pressed", self, "_on_emoji_selected")
	emojis_dnd_button.connect("pressed", self, "_on_emoji_dnd_button_pressed")


func _on_emoji_selected(pressed: TextureButton) -> void:
	emit_signal("emoji_pressed", pressed.name)


func _on_emoji_dnd_button_pressed():
	emit_signal("emoji_pressed", "Seventeen")

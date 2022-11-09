extends Node

var emoji_group: ButtonGroup = null
var current_emoji : String = "SomeEmojiName"
#var emoji_is_shown: bool = false

signal emoji_pressed(which)

# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_group = $One.group
	emoji_group.connect("pressed", self, "_on_emoji_selected")


func _on_emoji_selected(pressed: TextureButton) -> void:
	emit_signal("emoji_pressed", pressed.name)
	

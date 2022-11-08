extends Node

onready var grinningEmoji_button:TextureButton = $Panel/grinningEmoji


export (String) var current_emoji : String = "SomeEmojiName"
signal emoji_sent()
#var emoji_is_shown: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	grinningEmoji_button.connect("pressed", self, "_on_grinningEmoji_button_pressed")
	#$Panel/grinningEmoji.connect("emoji_sent", get_parent(), "_get_emoji")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_grinningEmoji_button_pressed() -> void:
	$"../TextureRect".show()
	print("Emoji button is pressed")
	$"../TextureRect/Timer".start()
	emit_signal("current_emoji")
	
	

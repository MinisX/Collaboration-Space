extends Node

onready var grinningEmoji_button:TextureButton = $Panel/grinningEmoji

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	grinningEmoji_button.connect("pressed", self, "_on_grinningEmoji_button_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_grinningEmoji_button_pressed() -> void:
	print("Emoji button is pressed")
	$"../TextureRect".show()
	#$"../TextureRect/Timer".start()
	#_on_Timer_timeout()


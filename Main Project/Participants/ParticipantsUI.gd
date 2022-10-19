extends Control

onready var participants_ok_button = $ParticipantsPanel/HideButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	participants_ok_button.connect("pressed", self, "_on_participants_ok_button_pressed")


func _on_participants_ok_button_pressed() -> void:
	self.hide()

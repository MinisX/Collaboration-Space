extends Control


onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton



# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.connect("pressed", self, "_on_back_pressed")


func _on_back_pressed() -> void:
	self.hide()

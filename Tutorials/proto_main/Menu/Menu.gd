extends Control

onready var continue_button: Button = $VBoxContainer/ContinueButton
onready var hot_keys_button: Button = $VBoxContainer/HotKeysButton
onready var exit_button: Button = $VBoxContainer/ExitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	continue_button.connect("pressed", self, "_on_continue_pressed")
	hot_keys_button.connect("pressed", self, "_on_hot_keys_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")
	

func _on_continue_pressed() -> void:
	pass
	
func _on_hot_keys_pressed() -> void:
	pass
	
func _on_exit_pressed() -> void:
	pass

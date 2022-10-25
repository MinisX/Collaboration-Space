extends Control

onready var continue_button: Button = $VBoxContainer/ContinueButton
onready var hot_keys_button: Button = $VBoxContainer/HotKeysButton
onready var exit_button: Button = $VBoxContainer/ExitButton
onready var hot_keys_scene = $HotKeys
onready var menu_button = $"../MenuButton"
onready var participants_button:Button = $"../ParticipantsButton"

# Called when the node enters the scene tree for the first time.
func _ready():
	continue_button.connect("pressed", self, "_on_continue_pressed")
	hot_keys_button.connect("pressed", self, "_on_hot_keys_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")


func _on_continue_pressed() -> void:
	self.hide()
	self.get_parent().get_parent().menu_visibility = false
	menu_button.show()
	participants_button.show()

func _on_hot_keys_pressed() -> void:
	hot_keys_scene.show()


func _on_exit_pressed() -> void:
	# TODO Safely remove the participant from the meeting
	# error 1: create_server: Couldn't create an ENet multiplayer server.
	# error 2: set_network_peer: Supplied NetworkedMultiplayerPeer must be connecting or connected.
	self.hide()
	get_parent().get_parent().queue_free()
	get_tree().change_scene("res://login/LoginScreen.tscn")

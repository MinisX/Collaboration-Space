extends Control

onready var continue_button: Button = $VBoxContainer/ContinueButton
onready var hot_keys_button: Button = $VBoxContainer/HotKeysButton
onready var exit_button: Button = $VBoxContainer/ExitButton
onready var hot_keys_scene = $HotKeys
onready var menu_button = $"../MenuButton"
onready var participants_button:Button = $"../ParticipantsButton"

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest

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
	if !Firebase.user_info.is_registered:
		Firebase.delete_account(http)
	else: 
		redirect_to_login()
	# TODO Safely remove the participant from the meeting
	# error 1: create_server: Couldn't create an ENet multiplayer server.
	# error 2: set_network_peer: Supplied NetworkedMultiplayerPeer must be connecting or connected.
	
func redirect_to_login() -> void:
	Firebase.user_info = {}
	self.hide()
	get_parent().get_parent().queue_free()
	get_tree().change_scene("res://login/LoginScreen.tscn")
	
# HTTP request to delete account for anon user when pressed "exit meeting"
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	if response_code == 200:
		print("\nHTTP Response: Code 200 -> User account deleted")
		redirect_to_login()
	else:
		print("\nHTTP Response: %s -> User account was not deleted" % response_code)

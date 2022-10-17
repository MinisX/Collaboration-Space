extends Control


# instantiate Member variables
onready var Username: LineEdit = $MarginContainer/VBoxContainer/UsernameEdit
onready var Password: LineEdit = $MarginContainer/VBoxContainer/PasswordEdit
onready var LoginButton: Button = $MarginContainer/VBoxContainer/LoginButton
onready var RegisterButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/RegisterButton
onready var JoinButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/JoinButton
onready var http : HTTPRequest = $HTTPRequest
onready var Notification : Label = $MarginContainer/VBoxContainer/Notification

func _ready() -> void:
	# Connect buttons to suitable callbacks
	JoinButton.connect("pressed", self, "_on_join_pressed")
	LoginButton.connect("pressed", self, "_on_LoginButton_pressed")
	RegisterButton.connect("pressed", self, "_on_RegisterButton_pressed")

# Called when login button is pressed
func _on_LoginButton_pressed():
	if Username.text.empty() or Password.text.empty():
		Notification.text = "Please, enter your username and password"
		return
	Firebase.login(Username.text, Password.text, http)
	
# Called when register button is pressed
func _on_RegisterButton_pressed():
	get_tree().change_scene("res://register/RegisterScreen.tscn")
	
# Called when join button is pressed
func _on_join_pressed() -> void:
#	Meeting.participant_data["name"] = Username.text
#	get_tree().change_scene("res://EnteringScene.tscn")
	get_tree().change_scene("res://Customization/Avatar.tscn")

# This function is called when we receive response on our HTTP request. This is done with use of HTTPRequest node, which
# is attached to Login scene
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response_body := JSON.parse(body.get_string_from_ascii())
	if response_code != 200:
		Notification.text = response_body.result.error.message.capitalize()
	else:
		Notification.text = "Sign in sucessful!"
		# After sucessful login redirect to UserProfile scene
		#yield(get_tree().create_timer(2.0), "timeout")
		GlobalData.participant_data["name"] = Username.text # Logic to be refined
		get_tree().change_scene("res://MeetingSpace.tscn")

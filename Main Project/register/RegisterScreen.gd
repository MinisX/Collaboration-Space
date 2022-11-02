extends Control

# instantiate Member variables
onready var Username: LineEdit = $MarginContainer/VBoxContainer/UsernameEdit
onready var Password: LineEdit = $MarginContainer/VBoxContainer/PasswordEdit
onready var RegisterButton: Button = $MarginContainer/VBoxContainer/RegisterButton
onready var LoginButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/LoginButton
onready var JoinButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/JoinButton
onready var http : HTTPRequest = $HTTPRequest
onready var Notification : Label = $MarginContainer/VBoxContainer/Notification

var anonLogin = false

func _ready() -> void:
	# Connect buttons to suitable callbacks
	JoinButton.connect("pressed", self, "_on_join_pressed")
	LoginButton.connect("pressed", self, "_on_LoginButton_pressed")
	RegisterButton.connect("pressed", self, "_on_RegisterButton_pressed")

# Called when register button is pressed
func _on_RegisterButton_pressed():
	# Check if input is correct
	if Username.text.empty() or Password.text.empty():
		Notification.text = "Invalid password or username"
		return
		
	# If check is ok, then we use our register function in Firebase script
	Firebase.register(Username.text, Password.text, http)

# Called when login button is pressed
func _on_LoginButton_pressed():
	get_tree().change_scene("res://login/LoginScreen.tscn")
	
# Called when join button is pressed
func _on_join_pressed() -> void:
	Firebase.anon_login(http)
	anonLogin = true


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response_body := JSON.parse(body.get_string_from_ascii())
	# If HTTP request is not OK, we provide response from Firebase as notification
	if response_code != 200:
		Notification.text = response_body.result.error.message.capitalize()
	else:
		Notification.text = "Registration sucessful!"
		#yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://Customization/Avatar.tscn")

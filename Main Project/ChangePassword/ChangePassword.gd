extends Control

# instantiate Member variables
onready var Password: LineEdit = $MarginContainer/VBoxContainer/PasswordEdit
onready var ChangeButton: Button = $MarginContainer/VBoxContainer/ChangeButton
onready var Notification : Label = $MarginContainer/VBoxContainer/Notification

onready var http : HTTPRequest = $HTTPRequest

func _on_ChangeButton_pressed():
	Firebase.change_password(Password.text, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response_body := JSON.parse(body.get_string_from_ascii())
	
	if response_code != 200:
		Notification.text = response_body.result.error.message.capitalize()
	else:
		Notification.text = "Password changed!"
		yield(get_tree().create_timer(2.0), "timeout")
		# Reset user info to null
		Firebase.user_info = {}
		get_tree().change_scene("res://login/LoginScreen.tscn")

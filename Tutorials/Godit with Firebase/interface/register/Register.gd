extends Control

onready var http : HTTPRequest = $HTTPRequest
# Here we get the access to the fields of the register screen
onready var username : LineEdit = $Container/VBoxContainer2/Username/LineEdit
onready var password : LineEdit = $Container/VBoxContainer2/Password/LineEdit
onready var confirm : LineEdit = $Container/VBoxContainer2/Confirm/LineEdit
onready var notification : Label = $Container/Notification

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var response_body := JSON.parse(body.get_string_from_ascii())

	# If HTTP request is not OK, we provide response from Firebase as notification
	if response_code != 200:
		notification.text = response_body.result.error.message.capitalize()
	else:
		notification.text = "Registration sucessful!"
		yield(get_tree().create_timer(2.0), "timeout")
		get_tree().change_scene("res://interface/login/Login.tscn")


func _on_RegisterButton_pressed():
	# Check if input is correct
	if password.text != confirm.text or username.text.empty() or password.text.empty():
		notification.text = "Invalid password or username"
		return
		
	# If check is ok, then we use our register function in Firebase script
	Firebase.register(username.text, password.text, http)

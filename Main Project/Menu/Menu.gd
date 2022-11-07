extends Control

onready var continue_button: Button = $VBoxContainer/ContinueButton
onready var hot_keys_button: Button = $VBoxContainer/HotKeysButton
onready var exit_button: Button = $VBoxContainer/ExitButton
onready var hot_keys_scene = $HotKeys
onready var menu_button = $"../MenuButton"
#onready var participants_button:Button = $CanvasLayer/ParticipantsButton

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest
# This variable counts the amount of HTTP responses/reuests
onready var http_responses_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	continue_button.connect("pressed", self, "_on_continue_pressed")
	hot_keys_button.connect("pressed", self, "_on_hot_keys_pressed")
	exit_button.connect("pressed", self, "_on_exit_pressed")


func _on_continue_pressed() -> void:
	self.hide()
	self.get_parent().get_parent().menu_visibility = false
	menu_button.show()
	#participants_button.show()

func _on_hot_keys_pressed() -> void:
	hot_keys_scene.show()


func _on_exit_pressed() -> void:
	#print("CHILDREN")
	#print(get_tree().get_root().get_children())
	Meeting.exit_meeting() 
	"""
	if !Firebase.user_info.is_registered:
		Firebase.delete_document("users/%s" % Firebase.user_info.id, http)
	else: 
		redirect_to_login()
	"""
	
# Helper method to redirect to login screen after logout
func redirect_to_login() -> void:
	Firebase.user_info = {}
	
	OS.execute(OS.get_executable_path(), [], false)
	get_tree().quit()
	
# HTTP request to delete account for anon user when pressed "exit meeting"
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	http_responses_count += 1
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if http_responses_count == 1:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User data deleted from DB, requesting delete of user account")
			Firebase.delete_account(http)
		else:
			print("\nHTTP Response: %s -> User data was not deleted" % response_code)
			
	if http_responses_count == 2:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User account was deleted")
			redirect_to_login()
		else:
			print("\nHTTP Response: %s -> User account not deleted" % response_code)

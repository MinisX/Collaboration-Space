extends YSort

#onready var particpant: KinematicBody2D = $Participant
onready var chat_button: Button = $CanvasLayer/ChatButton
onready var chat_UI = $CanvasLayer/ChatUI
onready var menu_UI = $CanvasLayer/MenuUI
onready var participants_button:Button = $CanvasLayer/ParticipantsButton
onready var menu_button:Button = $CanvasLayer/MenuButton

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest
# This variable counts the amount of HTTP responses/requests
onready var http_responses_count = 0

var menu_visibility: bool = false
var participants_UI_visibility: bool = false

func _ready() -> void:
	# Disable auto accept of quiting by cross
	# It's handeled in _notification method
	get_tree().set_auto_accept_quit(false)
	
	chat_button.connect("pressed", self, "_on_chat_button_pressed")
	participants_button.connect("pressed", self, "_on_participants_button_pressed")
	menu_button.connect("pressed", self, "_on_menu_button_pressed")
		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if menu_visibility == true:
			participants_button.show()
			menu_button.show()
			menu_UI.hide()
			menu_visibility = false
		else:
			participants_button.hide()
			menu_button.hide()
			menu_UI.show()
			menu_visibility = true


func _on_chat_button_pressed() -> void:
	chat_UI.show()

func _on_participants_button_pressed() -> void:
	if participants_UI_visibility ==false:
		$CanvasLayer/ParticipantsUI.show()
		participants_UI_visibility =true
	else:
		$CanvasLayer/ParticipantsUI.hide()
		participants_UI_visibility =false
		
func _on_menu_button_pressed() -> void:
		if menu_visibility == true:
			menu_button.show()
			menu_UI.hide()
			menu_visibility = false
			participants_button.show()
		else:
			menu_button.hide()
			menu_UI.show()
			menu_visibility = true
			participants_button.hide()

# Here we receive notification that user has pressed X to quit the game
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		if !Firebase.user_info.is_registered:
			Firebase.delete_document("users/%s" % Firebase.user_info.id, http)
		else: 
			get_tree().quit()
	# TODO Safely remove the participant from the meeting
	# error 1: create_server: Couldn't create an ENet multiplayer server.
	# error 2: set_network_peer: Supplied NetworkedMultiplayerPeer must be connecting or connected.
		#get_tree().quit()

# This is response from HTTP request when closing the window
# If user is anon, it's deleted. If registered, just logged off
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
			get_tree().quit()
		else:
			print("\nHTTP Response: %s -> User account not deleted" % response_code)

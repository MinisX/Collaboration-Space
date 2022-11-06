extends Control

onready var connection_panel: ColorRect = $ConnectionPanel
onready var name_input = Meeting.participant_data["Name"]
onready var online_button: Button = $ConnectionPanel/VBoxContainer/Row3/Online
onready var changePassword_button: Button = $ConnectionPanel/VBoxContainer/ChangePassword
onready var ip: String = "34.159.28.32"

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest
# This variable counts the amount of HTTP responses/requests
onready var http_responses_count = 0

func _ready() -> void:
	print("Lobby: _ready")
	# Disable auto accept of quiting by cross
	# It's handeled in _notification method
	get_tree().set_auto_accept_quit(false)
	
	# fetch if not --server
	# command line args example:
	# godot-server server.pck --server
	if "--server" in OS.get_cmdline_args():
		print("Lobby: --server")
	else:
		fetch_user_data_fromDB()
	
	# get ip address from argv
	var arguments: Dictionary = Meeting.get_cmd_args()
	if arguments.has("ip") and arguments["ip"].is_valid_ip_address():
		ip = arguments["ip"] as String
	
	# The signals are emitted ( sent ) from Meeting to Lobby
	# E.g connection_succeeded is sent from Meeting _connected_ok() method
	Meeting.connect("connection_succeeded", self, "_on_connection_success")
	Meeting.connect("meeting_ended", self, "_on_meeting_ended")
	Meeting.connect("meeting_error", self, "_on_meeting_error")
	
	# start meeting automaticaly after waiting 20 seconds if --server passed
	if "--server" in OS.get_cmdline_args():
		Meeting.host_meeting()
		Meeting.start_meeting()
	else:
		print("Main: client")

# This method is triggered from Meeting.gd in _connected_ok() method
func _on_connection_success() -> void:
	print("Lobby: _on_connection_success")
	
	# Hide the connection panel and show participants panel
	connection_panel.hide()
	# New joined user sends server ( id 1 ) 2 rpc packets
	# This packet asks for all the users already in the game
	Meeting.rpc_id(1,"server_participants_array")
	# This packet asks server to send all other users the new user info
	Meeting.rpc_id(1, "request_server_for_rpc_register", Meeting.participant_data)

func _on_meeting_ended() -> void:
	print("Lobby: _on_meeting_ended")
	
	self.show()
	connection_panel.show()
	
# This method is triggered from Meeting.gd in _server_disconnected() and _participant_disconnected() methods	
func _on_meeting_error(error) -> void:
	print("Lobby: _on_meeting_error")
	
	# We just print the error, the ending of the meeting is happening in Meeting.gd
	print(error)

func _on_online_pressed():
	print("Lobby: _on_online_pressed()")
	Meeting.join_meeting(ip)

func fetch_user_data_fromDB():
	print("Lobby: fetch_user_data_fromDB()")
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	
	# Hide change password if user is not registered
	if !Firebase.user_info.is_registered:
		changePassword_button.hide()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	http_responses_count += 1
	
	if http_responses_count == 1:
		var profile : = {
		"name": {},
		"hair": {},
		"eyes": {},
		"legs": {},
		"feet": {},
		"hands": {},
		"head": {},
		"torso": {},
		"arms": {}
		}
		
		var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
		
		if response_code == 200:
			print("HTTP Response: Code 200 -> Information fetched")
			profile = result_body.fields
			
			name_input = profile.name
			# new
			Meeting.participant_data["Name"] = profile.name["stringValue"]
			
			Meeting.participant_data["Color"]["Hair"] = Color(profile.hair["stringValue"])
			Meeting.participant_data["Color"]["Eyes"] = Color(profile.eyes["stringValue"])
			Meeting.participant_data["Color"]["Pants"] = Color(profile.legs["stringValue"])
			Meeting.participant_data["Color"]["Shoe"] = Color(profile.feet["stringValue"])
			# skin
			Meeting.participant_data["Color"]["Skin"] = Color(profile.hands["stringValue"])
			Meeting.participant_data["Color"]["Skin"] = Color(profile.head["stringValue"])
			# shirt
			Meeting.participant_data["Color"]["Shirt"] = Color(profile.torso["stringValue"])
			Meeting.participant_data["Color"]["Shirt"] = Color(profile.arms["stringValue"])

		else:
			print("HTTP Response: Not 200 -> Information not fetched")
			
	if http_responses_count == 2:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User data deleted from DB, requesting delete of user account")
			Firebase.delete_account(http)
		else:
			print("\nHTTP Response: %s -> User data was not deleted" % response_code)
			

	if http_responses_count == 3:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User account was deleted")
			self.show()
			connection_panel.show()
		else:
			print("\nHTTP Response: %s -> User account not deleted" % response_code)

func _on_ChangePassword_pressed():
	get_tree().change_scene("res://ChangePassword/ChangePassword.tscn")

func _on_Customize_avatar_pressed():
	get_tree().change_scene("res://Customization/Avatar.tscn")

# Here we receive notification that user has pressed X to quit the game
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print("Lobby.gd: Nofitication in first if")
		if !Firebase.user_info.is_registered:
			print("Lobby.gd: Nofitication in second if")
			get_tree().change_scene("res://Exit_Meeting/Exit_Meeting.tscn")
		else: 
			print("Lobby.gd: Nofitication in else")
			Firebase.user_info = {}
			get_tree().quit()

extends Control

onready var connection_panel: ColorRect = $ConnectionPanel
#onready var name_input = GlobalData.participant_data["Name"]
onready var name_input = Meeting.participant_data["Name"]
onready var participants_panel: ColorRect = $ParticipantsPanel
onready var participants_list_view: ItemList = $ParticipantsPanel/ParticipantList
onready var offline_button: Button = $ConnectionPanel/VBoxContainer/Row3/Offline
onready var online_button: Button = $ConnectionPanel/VBoxContainer/Row3/Online
onready var host_toggle: Button = $ConnectionPanel/VBoxContainer/Row3/Host
onready var start_button: Button = $ParticipantsPanel/Start
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
	
	# The signals are emitted ( sent ) from Meeting to Lobby
	# E.g connection_succeeded is sent from Meeting _connected_ok() method
	Meeting.connect("connection_failed", self, "_on_connection_failed")
	Meeting.connect("connection_succeeded", self, "_on_connection_success")
	Meeting.connect("participants_list_changed", self, "refresh_lobby")
	Meeting.connect("meeting_ended", self, "_on_meeting_ended")
	Meeting.connect("meeting_error", self, "_on_meeting_error")
	
	
	# button connections
	host_toggle.connect("pressed", self, "_on_host_pressed")
	start_button.connect("pressed", self, "_on_start_pressed")
	
	# start meeting automaticaly after waiting 20 seconds if --server passed
	if "--server" in OS.get_cmdline_args():
#		var delay: float = 15.0
		# check if there is another arguement (defines the amount of delay)
#		if OS.get_cmdline_args().size() == 3 and OS.get_cmdline_args()[2].is_valid_float():
#			delay = OS.get_cmdline_args()[2] as float
		Meeting.host_meeting()
	else:
		print("Main: client")

# set role(host or cl) of the participant
func _on_host_pressed() -> void:
	print("Lobby: _on_host_pressed()")
	if Meeting.participant_data["Role"] == "Host":
		Meeting.participant_data["Role"] = "Participant"
	elif Meeting.participant_data["Role"] == "Participant":
		Meeting.participant_data["Role"] = "Host"



# This method is triggered from Meeting.gd in _connected_ok() method
func _on_connection_success() -> void:
	print("Lobby: _on_connection_success")
	
	# Hide the connection panel and show participants panel
	connection_panel.hide()
	if Meeting.meeting_is_running == false:
		# Hide the connection panel and show participants panel
		connection_panel.hide()
		participants_panel.show()

# This method is triggered from Meeting.gd in _connected_fail() method
func _on_connection_failed() -> void:
	print("Lobby: _on_connection_failed")

func _on_meeting_ended() -> void:
	print("Lobby: _on_meeting_ended")
	
	"""
	if !Firebase.user_info.is_registered:
		Firebase.delete_document("users/%s" % Firebase.user_info.id, http)
	
	else:
	""" 
	self.show()
	connection_panel.show()
	participants_panel.hide()
	
# This method is triggered from Meeting.gd in _server_disconnected() and _participant_disconnected() methods	
func _on_meeting_error(error) -> void:
	print("Lobby: _on_meeting_error")
	
	# We just print the error, the ending of the meeting is happening in Meeting.gd
	print(error)
	
# This method is called triggered via signal " participants_list_changed " from Meeting in method register_participant()
func refresh_lobby() -> void:
	print("Lobby: refresh_lobby")
	
	var participants: Array = Meeting.get_participant_list()
	participants.sort()
	participants_list_view.clear()
	participants_list_view.add_item(Meeting.get_participant_name() + " (You)")
	for p in participants:
		participants_list_view.add_item(p["Name"])
	
func _on_offline_pressed():
	print("Lobby: _on_offline_pressed()")
	Meeting.host_meeting()
	refresh_lobby()
	Meeting.start_meeting()

func _on_online_pressed():
	print("Lobby: _on_online_pressed()")
	Meeting.join_meeting(ip)
	if Meeting.participant_data["Role"] == "Participant":
		start_button.hide()
		
func _on_JoinRunningGame_pressed():
	print("Lobby: _on_JoinRunningGame_pressed()")
	Meeting.join_running_game_pressed = true
	Meeting.meeting_is_running = true
	Meeting.join_meeting(ip)
	connection_panel.hide()

func _on_start_pressed():
	print("Lobby: _on_start_pressed()")
	if Meeting.participant_data["Role"] == "Host":
		# call start_meeting
		# use id 1 to call only on server  
		Meeting.rpc_id(1, "start_meeting")

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
			participants_panel.hide()
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

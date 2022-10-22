extends Control

onready var connection_panel: ColorRect = $ConnectionPanel
#onready var name_input = GlobalData.participant_data["Name"]
onready var name_input = Meeting.participant_data["Name"]
onready var participants_panel: ColorRect = $ParticipantsPanel
onready var participants_list_view: ItemList = $ParticipantsPanel/ParticipantList
onready var offline_button: Button = $ConnectionPanel/VBoxContainer/Row3/Offline
onready var online_button: Button = $ConnectionPanel/VBoxContainer/Row3/Online
onready var ip: String = "34.159.28.32" #34.159.28.32

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest

func _ready() -> void:
	print("Lobby: _ready")
	
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
	
	# start meeting automaticaly after waiting 20 seconds if --server passed
	if "--server" in OS.get_cmdline_args():
		Meeting.host_meeting()
		refresh_lobby()
		yield(get_tree().create_timer(20.0), "timeout")
		Meeting.start_meeting()
	else:
		print("Main: client")
	
# This method is triggered from Meeting.gd in _connected_ok() method
func _on_connection_success() -> void:
	print("Lobby: _on_connection_success")
	
	# Hide the connection panel and show participants panel
	connection_panel.hide()
	participants_panel.show()

# This method is triggered from Meeting.gd in _connected_fail() method
func _on_connection_failed() -> void:
	print("Lobby: _on_connection_failed")

func _on_meeting_ended() -> void:
	print("Lobby: _on_meeting_ended")
	
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
	Meeting.host_meeting()
	refresh_lobby()
	Meeting.start_meeting()

func _on_online_pressed():
	print("Lobby: _on_online_pressed")
	Meeting.join_meeting(ip)
	
func fetch_user_data_fromDB():
	print("Lobby: fetch_user_data_fromDB()")
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("HTTP Request Completed")
	
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












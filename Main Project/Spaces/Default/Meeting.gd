extends Node

# NETWORK RELATED STUFF START
# ---------------------------

# Confriration parameters
var DEFAULT_PORT: int = 1234
const MAX_PARTICIPANT: int = 30

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# This is a spawn_point of a user, which is defined per scene
var spawn_point : Vector2 = Vector2(0,0)

# Dictionary to store particpant name and custom colors
var participant_data: Dictionary = {
	Name = "name data",
	Color = {
		Hair = Color(1.0, 1.0, 1.0, 1.0),
		Skin = Color(1.0, 1.0, 1.0, 1.0),
		Eyes = Color(1.0, 1.0, 1.0, 1.0),
		Shirt = Color(1.0, 1.0, 1.0, 1.0),
		Pants = Color(1.0, 1.0, 1.0, 1.0),
		Shoe = Color(1.0, 1.0, 1.0, 1.0)
	},
	Sprite = "male",
	NetworkID = 0,
	selected_space = "Library",
	spawn_point = Vector2(0,0)
}

# participant datas for remote participants in id:participant_data format.
var participants: Dictionary = {}
var selected_space_server = "NA"

var is_chat_focused = false

# Signals to Lobby UI
# The signals are names that trigger function.
# E.g for participants_list_changed the function refresh_lobby in Lobby is triggered
signal connection_failed()
signal connection_succeeded()
signal meeting_ended()
signal meeting_error(what)
signal update_online()

# ---------------------------
# NETWORK RELATED STUFF END

func _ready() -> void:
	print("Meeting: _ready " + participant_data["Name"])
	# These signals are sent from NetworkedMultiplayerENet
	# E.g connected_to_server is sent from NetworkedMultiplayerENet to Meeting
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	# not sure about this!
#	Meeting.rset_config("selected_space", MultiplayerAPI.RPC_MODE_REMOTESYNC)
	
	# get argc to a dictionary
	var arguments: Dictionary = get_cmd_args()
	# change the default port if argv has port and it 
	if arguments.has("port") and arguments["port"].is_valid_integer():
		var port: int = arguments["port"] as int
		if port <= 65535:
			DEFAULT_PORT = arguments["port"] as int
			if DEFAULT_PORT == 1235:
				selected_space_server = "University"
			elif DEFAULT_PORT == 1236:
				selected_space_server = "Library"
			elif DEFAULT_PORT == 1237:
				selected_space_server = "Office"
			
	print(DEFAULT_PORT)

# get argc to a dictionary
# format of the args
# --key or --key=value
func get_cmd_args() -> Dictionary:
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			arguments[argument.lstrip("--")] = ""
	return arguments

# This method is triggered from a signal "network_peer_disconnected" from NetworkedMultiplayerENet 
func _participant_disconnected(id: int) -> void:
	print("Meeting: _participant_disconnected, ID: %s" % id)
		
	if id == 1:
		print("is_network_server == true")
		# Meeting sends signal "meeting_error " to Lobby, which triggers _on_meeting_error() method in Lobby
		# Second parameter is the message of the error
		emit_signal("meeting_error", "Server has been disconnected")
		end_meeting()
	else:
		print("is_network_server == false")
		# If the user disconnects ( not the server ), we just deregister him from the session
		# and continue the session without him
		unregister_participant(id)	

# This method is triggered from a signal "connected_to_server" from NetworkedMultiplayerENet 		
func _connected_ok() -> void:
	print("Meeting: _connected_ok, my ID is: %s" % get_tree().get_network_unique_id())
	var selected_space = participant_data["selected_space"]
	
	"""
	# Get the spawn point for current user ( defined per scene ), at the beginning it (0,0)
	spawn_point = get_node("/root/Default/"+selected_space+"/SpawnPoint").position
	"""
	
	# Send information to python script so that it registers us in the chat
	Client.send_user_id()
	# Add user id to particiant_data
	Meeting.participant_data["NetworkID"] = get_tree().get_network_unique_id()
	
	# Get access to Default scene
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	# Add Default.tscn as child of current screen
	get_tree().get_root().add_child(meeting_area)
	
	# Get the spawn point for current user ( defined per scene ), at the beginning it (0,0)
	# Initiate spawn point in participant data dictionary
	participant_data["spawn_point"] = get_node("/root/Default/"+selected_space+"/SpawnPoint").position
	spawn_point = participant_data["spawn_point"]
	
	# hide all spaces and show the selected one
	get_node("/root/Default/Library").hide()
	get_node("/root/Default/Office").hide()
	get_node("/root/Default/University").hide()
	get_node("/root/Default/"+selected_space).show()
	
	# remove unneeded nodes (they cause collision issues)
	if selected_space == "Library":
		print("Meeting: ", selected_space, " deleted (Office)")
		# get Office node and remove from Default scene
		var ch = get_node("/root/Default/Office")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/University")
		get_node("/root/Default").remove_child(ch)
		
		# is this necessary?
		# E 0:00:10.874   rpcp: Condition "!is_inside_tree()" is true.
		# <C++ Source>  scene/main/node.cpp:748 @ rpcp()
		# <Stack Trace> Meeting.gd:197 @ preconfigure_meeting()
		if not get_tree().is_network_server():
#			ch.rpc_id(1, "remove_me")
			pass
	elif selected_space == "Office":
		print("Meeting: ", selected_space, " deleted (Library)")
		# get Library node and remove from Default scene
		var ch = get_node("/root/Default/Library")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/University")
		get_node("/root/Default").remove_child(ch)
		
		# is this necessary?
		if not get_tree().is_network_server():
#			ch.rpc_id(1, "remove_me")
			pass
	elif selected_space == "University":
		var ch = get_node("/root/Default/Library")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/Office")
		get_node("/root/Default").remove_child(ch)
		
	# Hide lobby scene
	get_node("/root/Lobby").hide()
		
	# ---Add yourself to the scene----
	
	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")

	var participant = participant_scene.instance()

	participant.set_name(str(get_tree().get_network_unique_id()))
	# Set spawn locations for the participants
	participant.position = spawn_point
			
	# This means each other connected peer has authority over their own player.
	participant.set_network_master(get_tree().get_network_unique_id())

	participant.set_participant_camera(true)
	# set data (name and colors) to participant
	participant.set_data(participant_data)

	# Adds participant to participant list in Default scene
	meeting_area.get_node("Participants").add_child(participant)
	
	# Meeting sends signal " connection_succeeded " to Lobby, which triggers _on_connection_success() method in Lobby
	emit_signal("connection_succeeded")

# TODO
# This method is triggered from a signal "server_disconnected" from NetworkedMultiplayerENet
# In our case it seems like double code, as in _participant_disconnected there is also server option
# I will analyze this and perhaps remove
func _server_disconnected() -> void:
	print("Meeting: _server_disconnected")
	
	# Meeting sends signal "meeting_error " to Lobby, which triggers _on_meeting_error() method in Lobby
	# Second parameter is the message of the error
	emit_signal("meeting_error", "Server disconnected")
	end_meeting()

# This method is triggered from a signal "connection_failed" from NetworkedMultiplayerENet
func _connected_fail() -> void:
	print("Meeting: _connected_fail")
	
	# Current peer is sent to null ( removed from the netowkr )
	get_tree().set_network_peer(null)

# This method is triggered from the server and request is received by new joined client	
remote func new_user_adds_ingame_participants(participants_list_from_server : Array) -> void:
	print("Meeting: new_user_adds_ingame_participants()")
	var selected_space = participant_data["selected_space"]
	
	var participant_scene = load("res://Participant.tscn")
	
	for p in participants_list_from_server:
		print("Meeting: new_user_adds_ingame_participants(): adding user: %s " % p["NetworkID"])
		var spawn_point = p["spawn_point"]
		# Get access to participant scene

		var participant = participant_scene.instance()

		# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
		participant.set_name(str(p["NetworkID"]))
		# Set spawn locations for the participants
		participant.position = Vector2(spawn_point)
				
		# This means each other connected peer has authority over their own player.
		participant.set_network_master(p["NetworkID"])

		participant.set_participant_camera(false)
		# set data (name and colors) to participant
		participant.set_data(p)
		
		# Add participants to the list which is needed to see who's online
		participants[p["NetworkID"]] = p

		# Adds participant to participant list in Default scene
		get_tree().get_root().get_node("Default").get_node("Participants").add_child(participant)

# Server and participants that are already in game add new user	
func in_game_add_new_user(new_participant_data : Dictionary) -> void:
	print("Meeting: in_game_add_new_user(), adding user: %s" % new_participant_data["NetworkID"])
	var selected_space = participant_data["selected_space"]
	# Get the spawn point for current user ( defined per scene ), at the beginning it (0,0)
	var spawn_point = new_participant_data["spawn_point"]
	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")

	var participant = participant_scene.instance()

	participant.set_name(str(new_participant_data["NetworkID"]))
	# Set spawn locations for the participants
	participant.position = Vector2(spawn_point)
			
	# This means each other connected peer has authority over their own player.
	participant.set_network_master(new_participant_data["NetworkID"])

	participant.set_participant_camera(false)
	# set data (name and colors) to participant
	participant.set_data(new_participant_data)
	
	# Add participants to the list which is needed to see who's online
	participants[new_participant_data["NetworkID"]] = new_participant_data

	# Adds participant to participant list in Default scene
	get_tree().get_root().get_node("Default").get_node("Participants").add_child(participant)
	
	# If server, then send request to update how many users are online
	if get_tree().get_network_unique_id() == 1:
		print("Meeting: sending signal from server to update online")
		emit_signal("update_online")

# This method is called from user who has joined running game
# The call is done to server
# He sends his list of participants to the new user
remote func server_participants_array() -> void:
	print("Meeting: server_participants_array()")
	var rpc_sender: int = get_tree().get_rpc_sender_id()
	var participants_list_from_server: Array = get_participant_list()
	rpc_id(rpc_sender, "new_user_adds_ingame_participants", participants_list_from_server )
			
# This method is triggered from rpc_id call from _participant_connected() method in Meeting ( this script )	
# Remote keyword allows a function to be called by a remote procedure call (RPC).
# The remote keyword can be called by any peer, including the server and all clients. 
# The puppet keyword means a call can be made from the network 
# master to any network puppet. The master keyword means a call can be made from any network puppet to the network master.
remote func register_participant(new_participant_data: Dictionary) -> void:
	var id : int = new_participant_data["NetworkID"]
	print("Meeting: register_participant(), user %s" % id)
	# Here we get the rpc ID of the user that called register_participant

	if id != get_tree().get_network_unique_id():
		print("Meeting: register_participant(), inside if")
		in_game_add_new_user(new_participant_data)
		participants[id] = new_participant_data

# This request is only sent to the server	
remote func request_server_for_rpc_register(new_participant_data: Dictionary) -> void:
	print("Meeting: request_server_for_rpc_register(), user %s" % new_participant_data["NetworkID"])
	var id: int = get_tree().get_rpc_sender_id()
	in_game_add_new_user(new_participant_data)
	participants[id] = new_participant_data
	
	rpc("register_participant", new_participant_data)
	
# Unregister participant
func unregister_participant(id: int) -> void:
	print("Meeting: unregister_participant, ID: %s " % id)
	
	if has_node("/root/Default"):
		var childNode = get_tree().get_root().get_node("Default").get_node("Participants").get_node(str(id))
		get_tree().get_root().get_node("Default").get_node("Participants").remove_child(childNode)
	
	participants.erase(id)
	
	# If server, then send request to update how many users are online
	if get_tree().get_network_unique_id() == 1:
		print("Meeting: sending signal from server to update online")
		emit_signal("update_online")
	
# This method is triggered from rpc_id call from start_meeting() method in Meeting ( this cript )
# Remote keyword allows a function to be called by a remote procedure call (RPC).
# The remote keyword can be called by any peer, including the server and all clients. 
remote func preconfigure_meeting_server() -> void:
	print("Meeting: preconfigure_meeting, selected space: %s" % selected_space_server)
	
	if not "--server" in OS.get_cmdline_args():
		Client.send_user_id()
	# Get access to Default scene
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	# Add Default.tscn as child of current screen
	get_tree().get_root().add_child(meeting_area)
	
	# hide all spaces and show the selected one
	get_node("/root/Default/Library").hide()
	get_node("/root/Default/Office").hide()
	get_node("/root/Default/University").hide()
	get_node("/root/Default/"+selected_space_server).show()
	
	# remove unneeded nodes (they cause collision issues)
	if selected_space_server == "Library":
		print("Meeting: ", selected_space_server, " deleted (Office)")
		# get Office node and remove from Default scene
		var ch = get_node("/root/Default/Office")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/University")
		get_node("/root/Default").remove_child(ch)
		
		# is this necessary?
		# E 0:00:10.874   rpcp: Condition "!is_inside_tree()" is true.
		# <C++ Source>  scene/main/node.cpp:748 @ rpcp()
		# <Stack Trace> Meeting.gd:197 @ preconfigure_meeting()
		if not get_tree().is_network_server():
#			ch.rpc_id(1, "remove_me")
			pass
	elif selected_space_server == "Office":
		print("Meeting: ", selected_space_server, " deleted (Library)")
		# get Library node and remove from Default scene
		var ch = get_node("/root/Default/Library")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/University")
		get_node("/root/Default").remove_child(ch)
		
		# is this necessary?
		if not get_tree().is_network_server():
#			ch.rpc_id(1, "remove_me")
			pass
	elif selected_space_server == "University":
		print("Meeting: ", selected_space_server, " deleted (University)")
		var ch = get_node("/root/Default/Library")
		get_node("/root/Default").remove_child(ch)
		ch = get_node("/root/Default/Office")
		get_node("/root/Default").remove_child(ch)

	# Hide lobby scene
	get_node("/root/Lobby").hide()
	
	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")
	
	postconfigure_meeting()
	
# This method is triggered from rpc_id call from _start_meeting() method in Meeting ( this script )			
remote func postconfigure_meeting() -> void:
	print("Meeting: postconfigure_meeting")
	# Pause the scene
	get_tree().set_pause(false)
		
# This method creates the hosting on the game by server
func host_meeting() -> void:
	print("Meeting: host_meeting")
	# Initializing as a server, listening on the given port, with a given maximum number of peers
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PARTICIPANT)
	get_tree().set_network_peer(peer)
	
# Method for joining existing session
# This method is called when "online" button is pressed
func join_meeting(ip: String) -> void:
	print("Meeting: join_meeting")
	
	# Initializing as a client, connecting to a given IP and port:
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
# Get the list of participants
func get_participant_list() -> Array:
	print("Meeting: get_participant_list")
	
	return participants.values()
	
# Get the name of current participant
func get_participant_name() -> String:
	print("Meeting: get_participant_name")
	
	return participant_data["Name"]
	
remote func start_meeting() -> void:
	print("Meeting: start_meeting")
	assert(get_tree().is_network_server())

	preconfigure_meeting_server()

# TODO
# Check, this could be issue for the error	
func end_meeting() -> void:
	print("end_meeting: end_meeting")
	
	if has_node("/root/Default"):
		get_node("/root/Default").queue_free()

	emit_signal("meeting_ended")
	participants.clear()

func get_current_user_network_id() -> String:
	return str(get_tree().get_network_unique_id())
	
func exit_meeting() -> void:
	participants = {}
	
	var id = get_tree().get_network_unique_id()
	var childNode = get_tree().get_root().get_node("Default").get_node("Participants").get_node(str(id))
	get_tree().get_root().get_node("Default").get_node("Participants").remove_child(childNode)
	
	peer.close_connection()
	get_node("/root/Default").queue_free()
	emit_signal("meeting_ended")

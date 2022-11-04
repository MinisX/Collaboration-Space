extends Node

# NETWORK RELATED STUFF START
# ---------------------------

# Confriration parameters
var DEFAULT_PORT: int = 1235
const MAX_PARTICIPANT: int = 30

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# Default position of the user
var DEFAULT_POSITION = Vector2(250, 250)

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
	NetworkID = 0
}

# participant datas for remote participants in id:participant_data format.
var participants: Dictionary = {}

# Signals to Lobby UI
# The signals are names that trigger function.
signal connection_failed()
signal connection_succeeded()
signal meeting_ended()
signal meeting_error(what)

# ---------------------------
# NETWORK RELATED STUFF END

func _ready() -> void:
	print("Meeting: _ready " + participant_data["Name"])
	# These signals are sent from NetworkedMultiplayerENet
	# E.g connected_to_server is sent from NetworkedMultiplayerENet to Meeting
	
	# This signal is sent from NetworkPeer automatically and informs everyone about
	# Participant being disconnected.
	# SIGNAL OK
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	
	# This signal is sent from NetworkPeer automatically to the client who has connected
	# To the server succesfully
	# SIGNAL OK
	get_tree().connect("connected_to_server", self, "_connected_ok")
	
	# This signal is sent from NetworkPeer automatically to the client that the connection
	# To the server was not succesful
	# SIGNAL OK
	get_tree().connect("connection_failed", self, "_connected_fail")
	
	# This signal is sent from NetworkPeer automatically to the client that the server
	# has been disconnected
	# SIGNAL OK
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	# get argc to a dictionary
	var arguments: Dictionary = get_cmd_args()
	# change the default port if argv has port and it 
	if arguments.has("port") and arguments["port"].is_valid_integer():
		var port: int = arguments["port"] as int
		if port <= 65535:
			DEFAULT_PORT = arguments["port"] as int
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
# METHOD OK
func _participant_disconnected(id: int) -> void:
	print("Meeting: _participant_disconnected, ID: %s" % id)
		
	# If server is disconnected, then all users are informed about this and meeting is ended	
	if id == 1:
		print("is_network_server == true")
		# Meeting sends signal "meeting_error " to Lobby, which triggers _on_meeting_error() method in Lobby
		# Second parameter is the message of the error
		emit_signal("meeting_error", "Server has been disconnected")
		end_meeting()
	
	# If client has been disconnected, then we unregister the participant	
	else:
		print("is_network_server == false")
		# If the user disconnects ( not the server ), we just deregister him from the session
		# and continue the session without him
		unregister_participant(id)	

# This method is triggered from a signal "connected_to_server" from NetworkedMultiplayerENet
# After we are succesfully connected to server, we add ourselves do the scene
# METHOD OK 		
func _connected_ok() -> void:
	print("Meeting: _connected_ok")
	
	# Add user id to particiant_data
	Meeting.participant_data["NetworkID"] = get_tree().get_network_unique_id()
	
	# Get access to Default scene
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	# Add Default.tscn as child of current screen
	get_tree().get_root().add_child(meeting_area)
	# Hide lobby scene
	get_tree().get_root().get_node("Lobby").hide()
		
	# ---Add yourself to the scene----
	
	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")

	var participant = participant_scene.instance()

	participant.set_name(str(get_tree().get_network_unique_id()))
	# Set spawn locations for the participants
	participant.position = Vector2(Meeting.DEFAULT_POSITION)
			
	# This means each other connected peer has authority over their own player.
	participant.set_network_master(get_tree().get_network_unique_id())

	participant.set_participant_camera(true)
	# set data (name and colors) to participant
	participant.set_data(Meeting.participant_data)

	# Adds participant to participant list in Default scene
	meeting_area.get_node("Participants").add_child(participant)
	
	# Meeting sends signal " connection_succeeded " to Lobby, which triggers _on_connection_success() method in Lobby
	emit_signal("connection_succeeded")

# This method is triggered from a signal "server_disconnected" from NetworkedMultiplayerENet
# METHOD OK
func _server_disconnected() -> void:
	print("Meeting: _server_disconnected")
	
	# Meeting sends signal "meeting_error " to Lobby, which triggers _on_meeting_error() method in Lobby
	# Second parameter is the message of the error
	emit_signal("meeting_error", "Server disconnected")
	end_meeting()

# This method is triggered from a signal "connection_failed" from NetworkedMultiplayerENet
# METHOD OK
func _connected_fail() -> void:
	print("Meeting: _connected_fail")
	
	# Current peer is sent to null ( removed from the netowkr )
	get_tree().set_network_peer(null)

# METHOD OK
remote func new_user_adds_ingame_participants(participants_list_from_server : Array) -> void:
	print("Meeting: new_user_adds_ingame_participants()")
	
	for p in participants_list_from_server:
		# Get access to participant scene
		var participant_scene = load("res://Participant.tscn")

		var participant = participant_scene.instance()

		# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
		participant.set_name(str(p["NetworkID"]))
		# Set spawn locations for the participants
		participant.position = Vector2(DEFAULT_POSITION)
				
		# This means each other connected peer has authority over their own player.
		participant.set_network_master(p["NetworkID"])

		participant.set_participant_camera(false)
		# set data (name and colors) to participant
		participant.set_data(p)

		# Adds participant to participant list in Default scene
		get_tree().get_root().get_node("Default").get_node("Participants").add_child(participant)
	
# Server and participants that are already in game add new user	
func in_game_add_new_user(new_participant_data : Dictionary) -> void:
	print("Meeting: in_game_add_new_user()")
	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")

	var participant = participant_scene.instance()

	participant.set_name(str(new_participant_data["NetworkID"]))
	# Set spawn locations for the participants
	participant.position = Vector2(DEFAULT_POSITION)
			
	# This means each other connected peer has authority over their own player.
	participant.set_network_master(new_participant_data["NetworkID"])

	participant.set_participant_camera(false)
	# set data (name and colors) to participant
	participant.set_data(new_participant_data)

	# Adds participant to participant list in Default scene
	get_tree().get_root().get_node("Default").get_node("Participants").add_child(participant)
	
#----------------------
# TESTING METHODS END

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
# METHOD OK
remote func register_participant(new_participant_data: Dictionary) -> void:	
	print("Meeting: register:participant")
	# Here we get the rpc ID of the user that called register_participant
	var id: int = get_tree().get_rpc_sender_id()
	
	if id != 1 && id != get_tree().get_network_unique_id():
		in_game_add_new_user(new_participant_data)
			
	participants[id] = new_participant_data
	

# Unregister participant
# METHOD OK
func unregister_participant(id: int) -> void:
	print("Meeting: unregister_participant, ID: %s " % id)
	
	if has_node("/root/Default"):
		var childNode = get_tree().get_root().get_node("Default").get_node("Participants").get_node(str(id))
		get_tree().get_root().get_node("Default").get_node("Participants").remove_child(childNode)
	
	participants.erase(id)
	
# This method is triggered from rpc_id call from start_meeting() method in Meeting ( this cript )
# Remote keyword allows a function to be called by a remote procedure call (RPC).
# The remote keyword can be called by any peer, including the server and all clients. 
#remote func preconfigure_meeting(spawn_locations: Dictionary) -> void:
# METHOD OK
func preconfigure_meeting_server() -> void:
	print("Meeting: preconfigure_meeting_server")
	
	# Get access to Default scene
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	# Add Default.tscn as child of current screen
	get_tree().get_root().add_child(meeting_area)
	
	# Hide lobby scene
	get_tree().get_root().get_node("Lobby").hide()

	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")
	
	postconfigure_meeting()
	
# This method is triggered from rpc_id call from _start_meeting() method in Meeting ( this script )			
# METHOD OK
remote func postconfigure_meeting() -> void:
	print("Meeting: postconfigure_meeting")
	# Pause the scene
	get_tree().set_pause(false)

# This method creates the hosting on the game by server
# METHOD OK
func host_meeting() -> void:
	print("Meeting: host_meeting")
	
	# Initializing as a server, listening on the given port, with a given maximum number of peers
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PARTICIPANT)
	get_tree().set_network_peer(peer)
	
# Method for joining existing session
# This method is called when "online" button is pressed
# METHOD OK
func join_meeting(ip: String) -> void:
	print("Meeting: join_meeting")
	
	# Initializing as a client, connecting to a given IP and port:
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
# Get the list of participants
# METHOD OK
func get_participant_list() -> Array:
	print("Meeting: get_participant_list")
	
	return participants.values()
	
# Get the name of current participant
# METHOD OK
func get_participant_name() -> String:
	print("Meeting: get_participant_name")
	
	return participant_data["Name"]

# METHOD OK	
func start_meeting() -> void:
	print("Meeting: start_meeting")
	assert(get_tree().is_network_server())
	
	preconfigure_meeting_server()

# METHOD OK	
func end_meeting() -> void:
	print("end_meeting: end_meeting")
	
	if has_node("/root/Default"):
		get_node("/root/Default").queue_free()

	emit_signal("meeting_ended")
	participants.clear()

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

# Some data for testing
# ----------------------------
var meeting_is_running = false
var join_running_game_pressed = false
var meeting_area_running = null

var user1_id = 1887667424
var user2_id = 0
var user1_position = Vector2(419, 181)
var user2_position = Vector2(30, 30)
var user1_data: Dictionary = {
			Name = "user1",
			Color = {
				Hair = Color(1.0, 1.0, 1.0, 1.0),
				Skin = Color(1.0, 1.0, 1.0, 1.0),
				Eyes = Color(1.0, 1.0, 1.0, 1.0),
				Shirt = Color(1.0, 1.0, 1.0, 1.0),
				Pants = Color(1.0, 1.0, 1.0, 1.0),
				Shoe = Color(1.0, 1.0, 1.0, 1.0)
			},
			Role = "Host"
		}
		
var user2_data: Dictionary = {
			Name = "user2",
			Color = {
				Hair = Color(1.0, 1.0, 1.0, 1.0),
				Skin = Color(1.0, 1.0, 1.0, 1.0),
				Eyes = Color(1.0, 1.0, 1.0, 1.0),
				Shirt = Color(1.0, 1.0, 1.0, 1.0),
				Pants = Color(1.0, 1.0, 1.0, 1.0),
				Shoe = Color(1.0, 1.0, 1.0, 1.0)
			},
			Role = "Participant"
		}

#-----------------------------
# End of some data for testing

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
	Role = "Participant"
}

# participant datas for remote participants in id:participant_data format.
var participants: Dictionary = {}
var participants_ready: Array = []

# Signals to Lobby UI
# The signals are names that trigger function.
# E.g for participants_list_changed the function refresh_lobby in Lobby is triggered
signal participants_list_changed()
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
	get_tree().connect("network_peer_connected", self, "_participant_connected")
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
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

# This method is triggered from a signal "network_peer_connected" from NetworkedMultiplayerENet 
func _participant_connected(id: int) -> void:
	print("Meeting: _participant_connected, ID: %s " % id)
	
	# Start registration
	# The remote function register_participant of Meeting is triggered here
	# Here the signal is sent to another users to register the rpc caller at their game
	rpc_id(id, "register_participant", participant_data)
	
	# A little bit about RPC
	# To communicate between peers, the easiest way is to use RPCs (remote procedure calls). This is implemented as a set of functions in Node:
	# rpc("function_name", <optional_args>)
	# rpc_id(<peer_id>,"function_name", <optional_args>)

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
	print("Meeting: _connected_ok")
	
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
	
	# TODO
	# Not sure what this means
	get_tree().set_network_peer(null)
	
	# Meeting sends signal "meeting_error " to Lobby, which triggers _on_connection_failed() method in Lobby
	emit_signal("connection_failed")
	
# This method is triggered from rpc_id call from _participant_connected() method in Meeting ( this script )	
# Remote keyword allows a function to be called by a remote procedure call (RPC).
# The remote keyword can be called by any peer, including the server and all clients. 
# The puppet keyword means a call can be made from the network 
# master to any network puppet. The master keyword means a call can be made from any network puppet to the network master.
remote func register_participant(new_participant_data: Dictionary) -> void:	
	
	# Here we get the rpc ID of the user that called register_participant
	var id: int = get_tree().get_rpc_sender_id()
	print("Meeting: register_participant: ", id)
	print("Participant data: %s" % new_participant_data)
		
	# If statement for user1
	if meeting_is_running == true && id != 1 && join_running_game_pressed == false:
		print("In if statement for user 1")
		
		user2_id = id
		
		# Get access to participant scene
		var participant_scene = load("res://Participant.tscn")

		var participant = participant_scene.instance()

		# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
		participant.set_name(str(user2_id))
		# Set spawn locations for the participants
		participant.position = Vector2(user2_position)
			
		# This means each other connected peer has authority over their own player.
		participant.set_network_master(user2_id)

		participant.set_participant_camera(false)
		# set data (name and colors) to participant
		participant.set_data(user2_data)

		# Adds participant to participant list in Default scene
		#print("Meeting: preconfigure_meeting: adding child: %s" % participant)
		meeting_area_running.get_node("Participants").add_child(participant)
		
	# If statement for user2	
	if join_running_game_pressed == true && id == 1:
		print("In if statement for user2, adding user 2 ")
		
		# Get access to participant scene
		var participant_scene = load("res://Participant.tscn")

		var participant = participant_scene.instance()

		# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
		participant.set_name(str(user1_id))
		# Set spawn locations for the participants
		participant.position = Vector2(user1_position)
			
		# This means each other connected peer has authority over their own player.
		participant.set_network_master(user1_id)

		participant.set_participant_camera(false)
		# set data (name and colors) to participant
		participant.set_data(user1_data)

		# Adds participant to participant list in Default scene
		#print("Meeting: preconfigure_meeting: adding child: %s" % participant)
		meeting_area_running.get_node("Participants").add_child(participant)
		
		print("In if statement for user2, adding user 1 ")
		
		# Get access to participant scene
		var participant_scene_2 = load("res://Participant.tscn")

		var participant_2 = participant_scene_2.instance()

		# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
		participant.set_name(str(get_tree().get_network_unique_id()))
		# Set spawn locations for the participants
		participant.position = Vector2(user2_position)
			
		# This means each other connected peer has authority over their own player.
		participant.set_network_master(get_tree().get_network_unique_id())

		participant.set_participant_camera(true)
		# set data (name and colors) to participant
		participant.set_data(user2_data)

		# Adds participant to participant list in Default scene
		#print("Meeting: preconfigure_meeting: adding child: %s" % participant)
		meeting_area_running.get_node("Participants").add_child(participant)
	
	participants[id] = new_participant_data
	
	# Here we send signal to Lobby, which triggers refresh_lobby() method
	emit_signal("participants_list_changed")

# Unregister participant
func unregister_participant(id: int) -> void:
	print("Meeting: unregister_participant, ID: %s " % id)
	
	if has_node("/root/Default"):
		var childNode = get_tree().get_root().get_node("Default").get_node("Participants").get_node(str(id))
		get_tree().get_root().get_node("Default").get_node("Participants").remove_child(childNode)
	
	participants.erase(id)
	# Send signal to Lobby.gd, which triggers resfresh_lobby() method in Lobby
	emit_signal("participants_list_changed")
	
# This method is triggered from rpc_id call from start_meeting() method in Meeting ( this cript )
# Remote keyword allows a function to be called by a remote procedure call (RPC).
# The remote keyword can be called by any peer, including the server and all clients. 
remote func preconfigure_meeting(spawn_locations: Dictionary) -> void:
	print("Meeting: preconfigure_meeting")
	
	# Get access to Default scene
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	# Add Default.tscn as child of current screen
	get_tree().get_root().add_child(meeting_area)
	
	# Hide lobby scene
	get_tree().get_root().get_node("Lobby").hide()

	# Get access to participant scene
	var participant_scene = load("res://Participant.tscn")

	for p_id in spawn_locations:
		# Get access to participant instance
		# do not instance participant for server
		if p_id != 1:
			var participant = participant_scene.instance()

			# TODO ask Yufus and Fatma why is name set as p_id, which is spawn location
			participant.set_name(str(p_id))
			# Set spawn locations for the participants
			participant.position = spawn_locations[p_id]
			print("\n SPAWN LOCATIONS: %s \n" % spawn_locations)
			
			# This means each other connected peer has authority over their own player.
			participant.set_network_master(p_id)

			# If the participant is himself, then camera is set to him and his name is displayed
			if p_id == get_tree().get_network_unique_id():
				participant.set_participant_camera(true)
				# set data (name and colors) to participant 
				participant.set_data(participant_data)
				print("\n PARTICIPANT DATA: %s \n" % participant_data)
			# If participant is another player, then camera is not following him for current peer and name is set
			else:
				participant.set_participant_camera(false)
				# set data (name and colors) to participant
				participant.set_data(participants[p_id])

			# Adds participant to participant list in Default scene
			#print("Meeting: preconfigure_meeting: adding child: %s" % participant)
			meeting_area.get_node("Participants").add_child(participant)
			#print("Meeting: preconfigure_meeting: accessing child from node: %s" % meeting_area.get_node("Participants").get_children()[0])
			#var default = get_tree().get_root().get_node("Default").get_node("Participants").get_children()[0]
			#print("Accessing differentely: %s" % default)

	# If the current user is not server, we inform the server that the current user is ready
	# for the meeting to start
	if not get_tree().is_network_server():
		# Send RPC method call to ready_to_start() method here in Meeting.gd
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	# If there are no participants, we postconfigure the meeting
	elif participants.size() == 0:
		postconfigure_meeting()
	
# This method is triggered from rpc_id call from _start_meeting() method in Meeting ( this script )			
remote func postconfigure_meeting() -> void:
	print("Meeting: postconfigure_meeting")
	# Pause the scene
	meeting_is_running = true
	get_tree().set_pause(false)
	
# This method is triggered from rpc_id call from _preconfigure_meeting() method in Meeting ( this script )	
remote func ready_to_start(id: int) -> void:
	print("Meeting: ready_to_start")
	assert(get_tree().is_network_server())

	# If participant is not in participants_ready yet, then add him
	if not id in participants_ready:
		participants_ready.append(id)

	# If number of ready participants = total participants, postconfigure the meeting per each participant
	if participants_ready.size() == participants.size():
		for p in participants:
			rpc_id(p, "postconfigure_meeting")
		postconfigure_meeting()
		
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
	
	# If meeting is running, add default scene to the user who is trying to join
	# while game is already running. So that all users have the same tree
	if meeting_is_running:
		# Get access to Default scene
		meeting_area_running = load("res://Spaces/Default/Default.tscn").instance()
		# Add Default.tscn as child of current screen
		get_tree().get_root().add_child(meeting_area_running)
		# Hide lobby scene
		get_tree().get_root().get_node("Lobby").hide()
	
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
	
	randomize()
	var spawn_locations: Dictionary = {}
	spawn_locations[1] = Vector2(randi()%500, randi()%500)

	# Assign random spawn locations to participants
	for p in participants:
		spawn_locations[p] = Vector2(randi()%500, randi()%300)

	# Preconfigure meeting per each participants
	# This is RPC method call to remote preconfigure_meeting() method in Meeting script
	for p in participants:
		rpc_id(p, "preconfigure_meeting", spawn_locations)

	preconfigure_meeting(spawn_locations)
	
func end_meeting() -> void:
	print("end_meeting: end_meeting")
	
	if has_node("/root/Default"):
		get_node("/root/Default").queue_free()

	emit_signal("meeting_ended")
	participants.clear()

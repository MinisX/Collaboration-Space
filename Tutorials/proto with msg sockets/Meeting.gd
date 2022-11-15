extends Node

# Confriration parameters
const DEFAULT_PORT: int = 4242
const MAX_PARTICIPANT: int = 30

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# Name for my player.
var participant_name: String = "participant"

# Names for remote participants in id:name format.
var participants: Dictionary = {}
var participants_ready: Array = []

# Signals to Lobby UI
signal participants_list_changed()
signal connection_failed()
signal connection_succeeded()
signal meeting_ended()
signal meeting_error(what)

"""
var _server = WebSocketServer.new()
# The port we will listen to
const PORT = 9080
"""
var url = "141.59.136.68"
var _client = WebSocketClient.new()


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_participant_connected")
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_on_data")

	# Initiate connection to the given URL.
	var err = _client.connect_to_url(url, ["lws-mirror-protocol"])
	if err != OK:
		print("Unable to connect")
		set_process(false)
	"""
	_server.connect("data_received", self, "_on_data")
	# Start listening on the given port.
	var err = _server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	"""
#--------------------------------------------------------------------------------------------

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)

func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	print("Got data from server: ", _client.get_peer(1).get_packet().get_string_from_utf8())

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


"""

#Websocket method:
func _connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])

func _close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _disconnected(id, was_clean = false):
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _on_data(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = _server.get_peer(id).get_packet()
	print("Got data from client %d: %s ... echoing" % [id, pkt.get_string_from_utf8()])
	_server.get_peer(id).put_packet(pkt)

func _process(delta):
	# Call this in _process or _physics_process.
	# Data transfer, and signals emission will only happen when calling this function.
	_server.poll()
"""




















func _participant_connected(id: int) -> void:
	# Start registration
	rpc_id(id, "register_participant", participant_name)


func _participant_disconnected(id: int) -> void:
	if has_node("/root/MeetingArea"):
		if get_tree().is_network_server():
			emit_signal("meeting_error", "Participant " + participants[id] + " disconnected")
			end_meeting()
	else:
		unregister_participant(id)


func _connected_ok() -> void:
	emit_signal("connection_succeeded")


func _server_disconnected() -> void:
	emit_signal("meeting_error", "Server disconnected")
	end_meeting()


func _connected_fail() -> void:
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")


remote func register_participant(new_participant_name: String) -> void:
	var id: int = get_tree().get_rpc_sender_id()
	participants[id] = new_participant_name
	emit_signal("participants_list_changed")


func unregister_participant(id: int) -> void:
	participants.erase(id)
	emit_signal("participants_list_changed")


remote func preconfigure_meeting(spawn_locations: Dictionary) -> void:
	var meeting_area = load("res://MeetingArea.tscn").instance()
	get_tree().get_root().add_child(meeting_area)

	get_tree().get_root().get_node("Lobby").hide()

	var participant_scene = load("res://Participant.tscn")

	for p_id in spawn_locations:
		var participant = participant_scene.instance()

		participant.set_name(str(p_id))
		participant.position=spawn_locations[p_id]
		participant.set_network_master(p_id)

		if p_id == get_tree().get_network_unique_id():
			participant.set_participant_camera(true)
			participant.set_participant_name(participant_name)
		else:
			participant.set_participant_camera(false)
			participant.set_participant_name(participants[p_id])

		meeting_area.get_node("Participants").add_child(participant)

	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif participants.size() == 0:
		postconfigure_meeting()


remote func postconfigure_meeting() -> void:
	get_tree().set_pause(false)


remote func ready_to_start(id: int) -> void:
	assert(get_tree().is_network_server())

	if not id in participants_ready:
		participants_ready.append(id)

	if participants_ready.size() == participants.size():
		for p in participants:
			rpc_id(p, "postconfigure_meeting")
		postconfigure_meeting()

# Method that creates the host
func host_meeting(new_participant_name: String) -> void:
	print("host_meeting")
	participant_name = new_participant_name
	
	# Initializing as a server, listening on the given port, with a given maximum number of peers
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PARTICIPANT)
	get_tree().set_network_peer(peer)

# Method for joining existing session
func join_meeting(ip: String, new_participant_name: String) -> void:
	participant_name = new_participant_name
	
	# Initializing as a client, connecting to a given IP and port:
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_participant_list() -> Array:
	return participants.values()


func get_participant_name() -> String:
	return participant_name


func start_meeting() -> void:
	print("start_meeting")
	assert(get_tree().is_network_server())
	
	randomize()
	var spawn_locations: Dictionary = {}
	spawn_locations[1] = Vector2(randi()%500, randi()%500)

	for p in participants:
		spawn_locations[p] = Vector2(randi()%500, randi()%300)

	for p in participants:
		rpc_id(p, "preconfigure_meeting", spawn_locations)

	preconfigure_meeting(spawn_locations)


func end_meeting() -> void:
	if has_node("/root/MeetingArea"):
		get_node("/root/MeetingArea").queue_free()

	emit_signal("meeting_ended")
	participants.clear()




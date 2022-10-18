extends Node

const DEFAULT_PORT: int = 2000
const MAX_PARTICIPANT: int = 30

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


func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_participant_connected")
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


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
#	var meeting_area = load("res://MeetingArea.tscn").instance()
	var meeting_area = load("res://Spaces/Default/Default.tscn").instance()
	get_tree().get_root().add_child(meeting_area)

	get_tree().get_root().get_node("Lobby").hide()

	var participant_scene = load("res://Participant.tscn")

	for p_id in spawn_locations:
		var participant = participant_scene.instance()
		# participant.init(data) <- here 

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


func host_meeting(new_participant_name: String) -> void:
	participant_name = new_participant_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PARTICIPANT)
	get_tree().set_network_peer(peer)


func join_meeting(ip: String, new_participant_name: String) -> void:
	participant_name = new_participant_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_participant_list() -> Array:
	return participants.values()


func get_participant_name() -> String:
	return participant_name


func start_meeting() -> void:
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






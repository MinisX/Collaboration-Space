extends Node

# NETWORK RELATED STUFF START
# ---------------------------

# Confriration parameters
const DEFAULT_PORT: int = 4242
const MAX_PARTICIPANT: int = 30

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# Name for the player.
var participant_name: String = "participant"

# Names for remote participants in id:name format.
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
	# These signals are sent from NetworkedMultiplayerENet
	# E.g connected_to_server is sent from NetworkedMultiplayerENet to Meeting
	get_tree().connect("network_peer_connected", self, "_participant_connected")
	get_tree().connect("network_peer_disconnected", self,"_participant_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

# This method is triggered from a signal "network_peer_connected" from NetworkedMultiplayerENet 
func _participant_connected(id: int) -> void:
	print("Meeting: _participant_connected")
	
	# Start registration
	# The function register_participant of Meeting is triggered here
	rpc_id(id, "register_participant", participant_name)
	



extends Node

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# Name of the user
var participant_name: String = "participant"

# Method for joining existing session
func join_meeting(new_participant_name: String) -> void:
	print("join meeting")
	participant_name = new_participant_name
	
	# Initializing as a client, connecting to a given IP and port:
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(Lobby.SERVER_IP, Lobby.DEFAULT_PORT)
	get_tree().set_network_peer(peer)


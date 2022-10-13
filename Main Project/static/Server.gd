extends Node

# Create new NetworkedMultiplayerENet object. 
# It containts useful methods for serializing, sending and receiving data. On top of that, it adds methods to set a peer, 
# transfer mode, etc. It also includes signals that will let you know when peers connect or disconnect.
var peer: NetworkedMultiplayerENet = null

# Initializing as a server, listening on the given port, with a given maximum number of peers:
func host_meeting() -> void:
	print("host_meeting")
	
	# Initializing as a server, listening on the given port, with a given maximum number of peers
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(Lobby.DEFAULT_PORT, Lobby.MAX_PARTICIPANT)
	get_tree().set_network_peer(peer)

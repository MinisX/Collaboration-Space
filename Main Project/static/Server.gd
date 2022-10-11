extends Node

# Congfirurations
var SERVER_PORT = 5555
var MAX_PLAYERS = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer

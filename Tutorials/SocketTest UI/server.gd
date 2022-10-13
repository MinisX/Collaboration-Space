extends Node

# Our WebSocketClient instance
var client = WebSocketClient.new()

# The URL we will connect to
export var websocket_url = "ws://localhost:3000"

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	#_client.connect("connection_closed", self, "_closed")
	#_client.connect("connection_error", self, "_closed")
	#_client.connect("connection_established", self, "_connected")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	client.connect("data_received", self, "data_received")

	# Initiate connection to the given URL.
	var err = client.connect_to_url(websocket_url)
	if err != OK:
		set_process(false)
		print("Unable to connect")
		

func _process(delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	client.poll()


func data_received():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var payload = client.get_peer(1).get_packet().get_string_from_utf8()
	$debug.text += "Got message from server: " + payload

func send(msg):
	client.get_peer(1).put_packet(JSON.print(msg).to_utf8())
	
	
func _on_button_pressed():
	send($LineEdit.text)

"""
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
	client.get_peer(1).put_packet("Test packet".to_utf8())
"""

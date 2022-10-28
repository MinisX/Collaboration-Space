extends Node

# The URL we will connect to.
export var websocket_url = "ws://34.159.28.32:8765"
# Our WebSocketClient instance.
var _client = WebSocketClient.new()

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	# Initiate connection to the given URL.
	var err = _client.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)


func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Closed, clean: ", was_clean)
	set_process(false)


func _connected(proto = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Connected with protocol: ", proto)
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


func _process(_delta):
	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()


func _exit_tree():
	print("Client: _exit_tree")
	_client.disconnect_from_host(1001)

func send_to_server(id, room, state):
	var to_send = "{\"user_id\": " + id + ", \"room\": \"" + room + "\", \"state\": \"" + state + "\"}"
	_client.get_peer(1).put_packet(to_send.to_utf8())
	print("Client: send_to_server")
	print(to_send)

#extends Control
#
#
#onready var _line_edit = $HBoxContainer/VBoxContainer2/HBoxContainer/ChatTextEnter
#onready var _chat_text = $HBoxContainer/VBoxContainer2/ChatText
## onready var Client = $Client
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	# This signal is emitted when not using the Multiplayer API every time
#	# a full packet is received. Alternatively, you could check get_peer(1)
#	# .get_available_packets() in a loop.
#	Client._client.connect("data_received", self, "_on_data")
#	_chat_text.scroll_following = true
#	print("ChatUI: inside _ready called")
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
#
#func _on_data():
#	# Add the newly received message to chat, you MUST always use get_peer(1).
#	# get_packet to receive data from server, and not get_packet directly when 
#	# not using the MultiplayerAPI.
#	_chat_text.add_text(Client._client.get_peer(1).get_packet().get_string_from_utf8())
#	_chat_text.newline()
#	print("ChatUI: inside _on_data")
#	print(Client._client.get_peer(1).get_packet().get_string_from_utf8())
#
#
## Called when send button is pressed
#func _on_Send_pressed():
#	if _line_edit.text == "":
#		return
#	# Send the message to server.
#	# You MUST always use get_peer(1).put_packet to send data to server,
#	# and not put_packet directly when not using the MultiplayerAPI.
#	Client._client.get_peer(1).put_packet(_line_edit.text.to_utf8())
#	# Add text to text of the chat
#	_chat_text.add_text(_line_edit.text)
#	_chat_text.newline()
#	_line_edit.text = ""
#
#func send_to_server(id, room, state):
#	var to_send = "{\"user_id\": " + id + ", \"room\": \"" + room + "\", \"state\": \"" + state + "\"}"
#	Client._client.get_peer(1).put_packet(to_send.to_utf8())
#	print("ChatUI: inside send_to_server")

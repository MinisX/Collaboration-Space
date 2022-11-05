extends Control


onready var hide_button: Button = $ChatContainer/VBoxContainer/HBoxContainer/HideButton
onready var _chat_text: RichTextLabel = $ChatContainer/VBoxContainer/ChatText
onready var _line_edit: LineEdit = $ChatContainer/VBoxContainer/Chat/ChatEnter
onready var send_button: Button = $ChatContainer/VBoxContainer/Chat/SendButton
onready var participant_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	send_button.connect("pressed", self, "_on_send")
	hide_button.connect("pressed", self, "_on_hide")
	Client._client.connect("data_received", self, "_on_data")
	_chat_text.scroll_following = true
	_chat_text.bbcode_enabled = true
	print("ChatUI: inside _ready called")

	
func _on_data():
	# Add the newly received message to chat, you MUST always use get_peer(1).
	# get_packet to receive data from server, and not get_packet directly when 
	# not using the MultiplayerAPI.
	var received_data = JSON.parse(Client._client.get_peer(1).get_packet().get_string_from_utf8())
	print("Received data: ", received_data.result)
	if received_data.result != null:	
		if received_data.result["type"] == "retrieve_message":
			var json_messages = JSON.parse(received_data.result["result"].replace("'", "\""))
			print(json_messages.result)
			if typeof(json_messages.result) == TYPE_ARRAY:
				for document in json_messages.result:
					if "sender_name" in document and "message" in document:
						print("document: " ,document)
						_chat_text.append_bbcode("[color=blue]" + document["sender_name"] + "[/color]: " + document["message"])
						_chat_text.newline()
		elif received_data.result["type"] == "message":
			_chat_text.append_bbcode("[color=blue]" + received_data.result["name"] + "[/color]: " + received_data.result["msg"])
			_chat_text.newline()
	print("ChatUI: inside _on_data")
	print(Client._client.get_peer(1).get_packet().get_string_from_utf8())
	
func _on_send() -> void:
	# Empty text is not allowed
	if _line_edit.text.strip_edges(true, true) == "":
		return
	# Send the message to server.
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	#parse_json()Meeting.participant_data["Name"]
	var to_send = "{\"type\": \"message\", " + "\"msg\": \"" + _line_edit.text + "\"}"
	Client._client.get_peer(1).put_packet(to_send.to_utf8())
	# Add text to text of the chat
	_chat_text.append_bbcode("[color=blue]" + Meeting.participant_data["Name"] + "[/color]: " +_line_edit.text)
	_chat_text.newline()
	print("ChatUI: inside _on_send called")
	print(_line_edit.text)
	_line_edit.text = ""

func _on_hide() -> void:
	self.hide()

func _exit_tree():
	print("ChatUI: _exit_tree")

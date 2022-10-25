extends Control

# const MESSAGE = preload("res://ChatProposal/Message/Message.tscn")

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
	print("ChatUI: inside _ready called")
	
func _on_data():
	# Add the newly received message to chat, you MUST always use get_peer(1).
	# get_packet to receive data from server, and not get_packet directly when 
	# not using the MultiplayerAPI.
	_chat_text.add_text(Client._client.get_peer(1).get_packet().get_string_from_utf8())
	_chat_text.newline()
	print("ChatUI: inside _on_data")
	print(Client._client.get_peer(1).get_packet().get_string_from_utf8())
	
func send_to_server(id, room, state):
	var to_send = "{\"user_id\": " + id + ", \"room\": \"" + room + "\", \"state\": \"" + state + "\"}"
	Client._client.get_peer(1).put_packet(to_send.to_utf8())
	print("ChatUI: inside send_to_server")
	
func _on_send() -> void:
#	# var message = MESSAGE.instance()
#	message_container.add_child(message)
#	message.set_message_text(chat_text.text)
#	message.init_message("name", "everyone")
#	chat_text.text = ""
	if _line_edit.text == "":
		return
	# Send the message to server.
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	Client._client.get_peer(1).put_packet(_line_edit.text.to_utf8())
	# Add text to text of the chat
	_chat_text.add_text(_line_edit.text)
	_chat_text.newline()
	_line_edit.text = ""

func _on_hide() -> void:
	self.hide()

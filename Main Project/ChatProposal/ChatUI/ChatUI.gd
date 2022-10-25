extends Control

const MESSAGE = preload("res://ChatProposal/Message/Message.tscn")

onready var hide_button: Button = $ChatContainer/VBoxContainer/HBoxContainer/HideButton
onready var message_container: VBoxContainer = $ChatContainer/VBoxContainer/ItemList/MessageContainer
onready var chat_text: LineEdit = $ChatContainer/VBoxContainer/Chat/ChatText
onready var send_button: Button = $ChatContainer/VBoxContainer/Chat/SendButton
onready var participant_name: String


# Called when the node enters the scene tree for the first time.
func _ready():
	send_button.connect("pressed", self, "_on_send")
	hide_button.connect("pressed", self, "_on_hide")
	
func _on_send() -> void:
	var message = MESSAGE.instance()
	message_container.add_child(message)
	message.set_message_text(chat_text.text)
	message.init_message("name", "everyone")
	chat_text.text = ""

func _on_hide() -> void:
	self.hide()

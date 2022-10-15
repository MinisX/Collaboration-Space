extends MarginContainer

onready var avatar: TextureRect = $VBoxContainer/Avatar
onready var message_info: RichTextLabel = $VBoxContainer/MessageInfo
onready var message_text: Label = $VBoxContainer/MessageText
#onready var to_whom: String
#onready var participant_name: String

func set_message_text(text: String) -> void:
	message_text.text = text

func init_message(participant_name: String, to_whom: String) -> void:
#	participant_name = participant_name
#	to_whom = to_whom
	message_info.bbcode_text = "[color=#4ab3ff]" + participant_name + "[/color]" + " to " + to_whom

#func _ready():
#	pass

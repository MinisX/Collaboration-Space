extends Control


onready var _line_edit = $HBoxContainer/VBoxContainer2/HBoxContainer/ChatTextEnter
onready var _chat_text = $HBoxContainer/VBoxContainer2/ChatText


# Called when the node enters the scene tree for the first time.
func _ready():
	_chat_text.scroll_following = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Called when send button is pressed
func _on_Send_pressed():
	if _line_edit.text == "":
		return
	_chat_text.add_text(_line_edit.text)
	_chat_text.newline()
	_line_edit.text = ""

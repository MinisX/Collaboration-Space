extends YSort

#onready var particpant: KinematicBody2D = $Participant
onready var chat_button: Button = $CanvasLayer/ChatButton
onready var chat_UI = $CanvasLayer/ChatUI
onready var menu_UI = $CanvasLayer/MenuUI

var menu_visibility: bool = false

func _ready() -> void:
	#particpant.init(GlobalData.participant_data)
	chat_button.connect("pressed", self, "_on_chat_button_pressed")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if menu_visibility == true:
			menu_UI.hide()
			menu_visibility = false
		else:
			menu_UI.show()
			menu_visibility = true

func _on_chat_button_pressed() -> void:
	chat_UI.show()

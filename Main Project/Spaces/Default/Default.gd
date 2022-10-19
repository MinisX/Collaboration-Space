extends YSort

#onready var particpant: KinematicBody2D = $Participant
onready var chat_button: Button = $CanvasLayer/ChatButton
onready var chat_UI = $CanvasLayer/ChatUI
onready var menu_UI = $CanvasLayer/MenuUI
onready var participants_button = $CanvasLayer/ParticipantsButton
onready var participants_ok_button = $CanvasLayer/ParticipantsUI/ParticipantsPanel/HideButton

var menu_visibility: bool = false

func _ready() -> void:
	#particpant.init(GlobalData.participant_data)
	chat_button.connect("pressed", self, "_on_chat_button_pressed")
	participants_button.connect("pressed", self, "_on_participants_button_pressed")
	participants_ok_button.connect("Ok pressed", self, "_on_participants_ok_button_pressed")

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

func _on_participants_button_pressed() -> void:
	$CanvasLayer/ParticipantsUI.show()
	
func _on_participants_ok_button_pressed() -> void:
	$CanvasLayer/ParticipantsUI.hide()

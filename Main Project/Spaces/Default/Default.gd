extends YSort

onready var particpant: KinematicBody2D = $Participant
onready var chat_button: Button = $CanvasLayer/ChatButton
onready var chat_UI = $CanvasLayer/ChatUI


func _ready() -> void:
	particpant.init(Meeting.participant_data)
	chat_button.connect("pressed", self, "_on_chat_button_pressed")

func _on_chat_button_pressed() -> void:
	chat_UI.show()

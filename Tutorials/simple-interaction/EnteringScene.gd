extends Control


onready var join_button: Button = $VBoxContainer/JoinButton
onready var participant_name_input: LineEdit = $VBoxContainer/ParticipantName

func _ready() -> void:
	join_button.connect("pressed", self, "_on_join_pressed")

func _on_join_pressed() -> void:
	Meeting.participant_name = participant_name_input.text
	get_tree().change_scene("res://MeetingSpace.tscn")


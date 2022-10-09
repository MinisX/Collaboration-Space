extends Control

# instantiate Member variables
onready var join_button: Button = $MarginContainer/VBoxContainer/JoinButton
onready var LoginButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/LoginButton
onready var RegisterButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/RegisterButton
onready var participant_name_input: LineEdit = $MarginContainer/VBoxContainer/ParticipantName

func _ready() -> void:
	# Connect buttons to suitable callbacks
	join_button.connect("pressed", self, "_on_join_pressed")		
	LoginButton.connect("pressed", self, "_on_LoginButton_pressed")
	RegisterButton.connect("pressed", self, "_on_RegisterButton_pressed")

# Called when join button is pressed
func _on_join_pressed() -> void:
	Meeting.participant_name = participant_name_input.text
	get_tree().change_scene("res://MeetingSpace.tscn")

# Called when login button is pressed
func _on_LoginButton_pressed():
	get_tree().change_scene("res://LoginScreen.tscn")

# Called when register button is pressed
func _on_RegisterButton_pressed():
	get_tree().change_scene("res://RegisterScreen.tscn")

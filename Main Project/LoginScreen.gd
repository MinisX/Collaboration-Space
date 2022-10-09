extends Control


# instantiate Member variables
onready var Username: LineEdit = $MarginContainer/VBoxContainer/UsernameEdit
onready var Password: LineEdit = $MarginContainer/VBoxContainer/PasswordEdit
onready var LoginButton: Button = $MarginContainer/VBoxContainer/LoginButton
onready var RegisterButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/RegisterButton
onready var JoinButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/JoinButton

func _ready() -> void:
	# Connect buttons to suitable callbacks
	JoinButton.connect("pressed", self, "_on_join_pressed")		
	LoginButton.connect("pressed", self, "_on_LoginButton_pressed")
	RegisterButton.connect("pressed", self, "_on_RegisterButton_pressed")

# Called when login button is pressed
func _on_LoginButton_pressed():
	Meeting.participant_name = Username.text
	get_tree().change_scene("res://MeetingSpace.tscn")
	
# Called when register button is pressed
func _on_RegisterButton_pressed():
	get_tree().change_scene("res://RegisterScreen.tscn")
	
# Called when join button is pressed
func _on_join_pressed() -> void:
	Meeting.participant_name = Username.text
	get_tree().change_scene("res://EnteringScene.tscn")

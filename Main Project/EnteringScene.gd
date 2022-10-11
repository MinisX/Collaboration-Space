extends Control

# instantiate Member variables
onready var join_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/JoinButton
onready var customize_button: Button = $MarginContainer/VBoxContainer/HBoxContainer2/CustomizeButton
onready var LoginButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/LoginButton
onready var RegisterButton: Button = $MarginContainer/VBoxContainer/HBoxContainer/RegisterButton
onready var participant_name_input: LineEdit = $MarginContainer/VBoxContainer/ParticipantName
onready var back_button: Button = $CustomizeUI_Container/HBoxContainer/BackButton
onready var avatar = $CustomizeUI_Container/HBoxContainer/Avatar

func _ready() -> void:
	# Connect buttons to suitable callbacks
	join_button.connect("pressed", self, "_on_join_pressed")
	customize_button.connect("pressed", self, "_on_customize_pressed")
	LoginButton.connect("pressed", self, "_on_LoginButton_pressed")
	RegisterButton.connect("pressed", self, "_on_RegisterButton_pressed")
	back_button.connect("pressed", self, "_on_back_button_pressed")

# Called when join button is pressed
func _on_join_pressed() -> void:
	Meeting.participant_data["Name"] = participant_name_input.text
	get_tree().change_scene("res://MeetingSpace.tscn")
	
func _on_customize_pressed() -> void:
	$MarginContainer.hide()
	$CustomizeUI_Container.show()

func _on_back_button_pressed() -> void:
	$MarginContainer.show()
	$CustomizeUI_Container.hide()

# Called when login button is pressed
func _on_LoginButton_pressed():
	get_tree().change_scene("res://login/LoginScreen.tscn")

# Called when register button is pressed
func _on_RegisterButton_pressed():
	get_tree().change_scene("res://register/RegisterScreen.tscn")
	

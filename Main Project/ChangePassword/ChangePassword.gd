extends Control

# instantiate Member variables
onready var Password: LineEdit = $MarginContainer/VBoxContainer/PasswordEdit
onready var ChangeButton: Button = $MarginContainer/VBoxContainer/ChangeButton
onready var Notification : Label = $MarginContainer/VBoxContainer/Notification

onready var http : HTTPRequest = $HTTPRequest

func _on_ChangeButton_pressed():
	pass # Replace with function body.

extends YSort

#onready var particpant: KinematicBody2D = $Participant
onready var chat_button: Button = $CanvasLayer/ChatButton
onready var chat_UI = $CanvasLayer/ChatUI
onready var menu_UI = $CanvasLayer/MenuUI

onready var menu_button:Button = $CanvasLayer/MenuButton
onready var chat_input: LineEdit  = $CanvasLayer/ChatUI/ChatContainer/VBoxContainer/Chat/ChatEnter
#onready var participants_button:Button = $CanvasLayer/ParticipantsButton

var menu_visibility: bool = false



func _ready() -> void:
	# Disable auto accept of quiting by cross
	# It's handeled in _notification method
	# get_tree().set_auto_accept_quit(false)

	chat_button.connect("pressed", self, "_on_chat_button_pressed")

	menu_button.connect("pressed", self, "_on_menu_button_pressed")
	chat_input.connect("focus_entered", self, "_on_chat_focused")
	chat_input.connect("focus_exited", self, "_on_chat_unfocused")

		
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if menu_visibility == true:
			#participants_button.hide()
			menu_button.show()
			menu_UI.hide()
			menu_visibility = false
		else:
			#participants_button.show()
			menu_button.hide()
			menu_UI.show()
			menu_visibility = true

func _on_chat_focused() -> void:
	Meeting.is_chat_focused = true

func _on_chat_unfocused() -> void:
	Meeting.is_chat_focused = false

func _on_chat_button_pressed() -> void:
	chat_UI.show()


		
func _on_menu_button_pressed() -> void:
		if menu_visibility == true:
			menu_button.show()
			menu_UI.hide()
			menu_visibility = false
			#participants_button.show()
		else:
			menu_button.hide()
			menu_UI.show()
			menu_visibility = true
			#participants_button.hide()


"""
# Here we receive notification that user has pressed X to quit the game
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		print("Default.gd: Notification in first if")
		
		if !Firebase.user_info.is_registered:
			print("Default.gd: Notification in second if")
			get_tree().change_scene("res://Exit_Meeting/Exit_Meeting.tscn")
		else: 
			print("Default.gd: Notification in else")
			Firebase.user_info = {}
			get_tree().quit()
"""


extends Control

onready var connection_panel: ColorRect = $ConnectionPanel
onready var name_input = GlobalData.participant_data["Name"]
onready var participants_panel: ColorRect = $ParticipantsPanel
onready var participants_list_view: ItemList = $ParticipantsPanel/ParticipantList
onready var offline_button: Button = $ConnectionPanel/VBoxContainer/Row3/Offline
onready var online_button: Button = $ConnectionPanel/VBoxContainer/Row3/Online

func _ready() -> void:
	print("Lobby: _ready")
	
	# The signals are emitted ( sent ) from Meeting to Lobby
	# E.g connection_succeeded is sent from Meeting _connected_ok() method
	Meeting.connect("connection_failed", self, "_on_connection_failed")
	Meeting.connect("connection_succeeded", self, "_on_connection_success")
	Meeting.connect("participants_list_changed", self, "refresh_lobby")
	Meeting.connect("meeting_ended", self, "_on_meeting_ended")
	Meeting.connect("meeting_error", self, "_on_meeting_error")
	
	# ui connections
	offline_button.connect("pressed", self, "_on_offline_pressed")
	online_button.connect("pressed", self, "_on_online_pressed")
	
	
# When 
func _on_connection_success() -> void:
	print("Lobby: _on_connection_success")
	
	connection_panel.hide()
	participants_panel.show()

func _on_connection_failed() -> void:
	print("Lobby: _on_connection_failed")

func _on_meeting_ended() -> void:
	print("Lobby: _on_meeting_ended")
	
	self.show()
	connection_panel.show()
	participants_panel.hide()
	
func _on_offline_pressed():
	get_tree().change_scene("res://Spaces/Default/Default.tscn")


func _on_online_pressed():
	pass # Replace with function body.

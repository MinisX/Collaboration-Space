extends Control

onready var start_button: Button = $ParticipantsPanel/StartButton
onready var host_button: Button = $ConnectionPanel/VBoxContainer/Row3/HostButton
onready var join_button: Button = $ConnectionPanel/VBoxContainer/Row3/JoinButton
onready var name_input: LineEdit = $ConnectionPanel/VBoxContainer/Row1/NameInput
onready var ip_input: LineEdit = $ConnectionPanel/VBoxContainer/Row2/IP_Input
onready var connection_panel: ColorRect = $ConnectionPanel
onready var participants_panel: ColorRect = $ParticipantsPanel
onready var participants_list_view: ItemList = $ParticipantsPanel/ParticipantList

func _ready() -> void:
	# Network Related
	Meeting.connect("connection_failed", self, "_on_connection_failed")
	Meeting.connect("connection_succeeded", self, "_on_connection_success")
	Meeting.connect("participants_list_changed", self, "refresh_lobby")
	Meeting.connect("meeting_ended", self, "_on_meeting_ended")
	Meeting.connect("meeting_error", self, "_on_meeting_error")
	# ui connections
	start_button.connect("pressed", self, "_on_start_pressed")
	host_button.connect("pressed", self, "_on_host_pressed")
	join_button.connect("pressed", self, "_on_join_pressed")
	# defult name and default ip
	name_input.text = "participant"
	ip_input.text = "127.0.0.1"

func _on_host_pressed() -> void:
	connection_panel.hide()
	participants_panel.show()

	Meeting.host_meeting(name_input.text)
	refresh_lobby()


func _on_join_pressed() -> void:
	var ip: String = ip_input.text
	if not ip.is_valid_ip_address():
		print("Invalid IP address!")
		return

	host_button.disabled = true
	join_button.disabled = true

	Meeting.join_meeting(ip, name_input.text)


func _on_connection_success() -> void:
	connection_panel.hide()
	participants_panel.show()

func _on_connection_failed() -> void:
	host_button.disabled = false
	join_button.disabled = false

func _on_meeting_ended() -> void:
	self.show()
	connection_panel.show()
	participants_panel.hide()
	host_button.disabled = false
	join_button.disabled = false


func _on_meeting_error(error) -> void:
	print(error)
	host_button.disabled = false
	join_button.disabled = false

func refresh_lobby() -> void:
	var participants: Array = Meeting.get_participant_list()
	participants.sort()
	participants_list_view.clear()
	participants_list_view.add_item(Meeting.get_participant_name() + " (You)")
	for p in participants:
		participants_list_view.add_item(p)

	start_button.disabled = not get_tree().is_network_server()


func _on_start_pressed() -> void:
	Meeting.start_meeting()



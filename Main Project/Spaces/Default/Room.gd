extends Area2D

export (String) var room_name: String

var participants_inside: Array = []

# {Name = "room name", ListOfParticipants = participants_inside}
var room_info: Dictionary = {}

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

remotesync func remove_me() -> void:
	print("------------------- Room: remove_me")
	self.queue_free()

func _process(delta) -> void:
	# print participants_inside array when "ui_accept" pressed
	if Input.is_action_just_pressed("ui_accept"):
		print(participants_inside, " are in ", room_name)
		print("room info: ", get_room_info())

# This function returns room info (room name and list of participants in side of a room) 
func get_room_info() -> String:
	room_info["Name"] = room_name
	room_info["ListOfParticipants"] = participants_inside
	return JSON.print(room_info)

# push id of a participant to "participants_inside" array
func _on_body_entered(body: KinematicBody2D) -> void:
	if body:
		print(body.name)
		print(Meeting.get_current_user_network_id())
		if body.name == Meeting.get_current_user_network_id():
			print("Room: ", "participant: " + Firebase.user_info.id + " entered to the room ", room_name)
			Client.send_to_server(Firebase.user_info.id, room_name, "join")

# remove id of a participant from "participants_inside" array
func _on_body_exited(body: KinematicBody2D) -> void:
	if body:
		print(body.name)
		print(Meeting.get_current_user_network_id())
		if body.name == Meeting.get_current_user_network_id():
			print("Room: ", "participant: " + Firebase.user_info.id + " exited from the room ", room_name)
			Client.send_to_server(Firebase.user_info.id, room_name, "depart")
			get_tree().get_root().get_node("Default/CanvasLayer/ChatUI/ChatContainer/VBoxContainer/ChatText").clear()

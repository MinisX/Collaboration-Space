extends Area2D

export (String) var room_name: String

var Chatui = load("res://ChatProposal/ChatUI/ChatUI.gd").new()
var participants_inside: Array = []

# {Name = "room name", ListOfParticipants = participants_inside}
var room_info: Dictionary = {}

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	self.connect("body_exited", self, "_on_body_exited")


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
		print("Room: ", "participant: ", body.name, " entered to the room ", room_name)
		participants_inside.push_back(body.name)
		Chatui.send_to_server(body.name, "room_1", "join")

# remove id of a participant from "participants_inside" array
func _on_body_exited(body: KinematicBody2D) -> void:
	if body:
		print("Room: ", "participant: ", body.name, " exited from the room ", room_name)
		participants_inside.erase(body.name)
		Chatui.send_to_server(body.name, "room_1", "depart")


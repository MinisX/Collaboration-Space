extends Area2D

export (String) var room_name: String

var participants_inside: Array = []

func _ready():
	self.connect("body_entered", self, "_on_body_entered")
	self.connect("body_exited", self, "_on_body_exited")


func _process(delta) -> void:
	# print participants_inside array when "ui_accept" pressed
	if Input.is_action_just_pressed("ui_accept"):
		print(participants_inside, " are in ", room_name)

# This function returns the list of participants in side of a room 
func get_participant_list() -> Array:
	return participants_inside

# push id of a participant to "participants_inside" array
func _on_body_entered(body: KinematicBody2D) -> void:
	if body:
		print("Room: ", "participant: ", body.name, " entered to the room ", room_name)
		participants_inside.push_back(body.name)

# remove id of a participant from "participants_inside" array
func _on_body_exited(body: KinematicBody2D) -> void:
	if body:
		print("Room: ", "participant: ", body.name, " exited from the room ", room_name)
		participants_inside.erase(body.name)


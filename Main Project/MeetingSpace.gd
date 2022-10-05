extends Node2D

onready var particpant: KinematicBody2D = $Participant

func _ready() -> void:
	particpant.set_participant_name(Meeting.participant_name)

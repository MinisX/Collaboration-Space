extends Node2D

onready var particpant: KinematicBody2D = $YSort/Participant

func _ready() -> void:
	particpant.init(Meeting.participant_data)

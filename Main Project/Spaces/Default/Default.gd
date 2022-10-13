extends YSort

onready var particpant: KinematicBody2D = $Participant

func _ready() -> void:
	particpant.init(Meeting.participant_data)

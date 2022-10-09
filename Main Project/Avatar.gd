extends KinematicBody2D



func _ready():
	pass

func set_body_color(color: Color) -> void:
	$Torso.modulate = color
	$Head.modulate = color
	$Legs.modulate = color
	$Feet.modulate = color
	$Hands.modulate = color
	$Arms.modulate = color



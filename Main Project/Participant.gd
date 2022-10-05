extends KinematicBody2D

export (float) var speed: float = 10000.0

var velocity: Vector2 = Vector2(0.0, 0.0)

onready var participant_name: Label = $Name

func _ready() -> void:
	participant_name.text = "Participant"

func _process(delta: float) -> void:
	get_input()
	velocity = move_and_slide(velocity*delta)

func get_input() -> void:
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func set_participant_name(new_name: String) -> void:
	participant_name.text = new_name


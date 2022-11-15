extends KinematicBody2D


export (float) var speed: float = 100.0

onready var participant_name: Label = $Name

puppet var puppet_pos: Vector2 = Vector2()
puppet var puppet_motion: Vector2 = Vector2()


func _process(_delta: float) -> void:
	var motion: Vector2 = Vector2()

	if is_network_master():
		if Input.is_action_pressed("ui_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("ui_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("ui_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("ui_down"):
			motion += Vector2(0, 1)

		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion

	move_and_slide(motion * speed)
	if not is_network_master():
		puppet_pos = position


func set_participant_name(new_name: String) -> void:
	$Name.text = new_name

func set_participant_camera(active: bool) -> void:
	$Camera.current = active

func _ready() -> void:
	#speed = 100#speed*10000.0
	puppet_pos = position

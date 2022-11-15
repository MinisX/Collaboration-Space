extends KinematicBody2D

export (float) var speed: float = 10000.0

var velocity: Vector2 = Vector2(0.0, 0.0)

onready var participant_name: Label = $Name
onready var interaction_range: Area2D = $InteractionRange

var interaction_active: bool = false

func _ready() -> void:
	participant_name.text = "Participant"
	
	interaction_range.connect("body_entered", self, "_on_interaction_range_entered")
	interaction_range.connect("body_exited", self, "_on_interaction_range_exited")

func _process(delta: float) -> void:
	get_input()
	velocity = move_and_slide(velocity*delta)
	if Input.is_action_just_pressed("ui_accept") and interaction_active:
		print("chat")
		

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


func _on_interaction_range_entered(body) -> void:
	if body != self:
		interaction_active = true
		print("interaction: ", interaction_active)

func _on_interaction_range_exited(body) -> void:
	if body != self:
		interaction_active = false
		print("interaction: ", interaction_active)



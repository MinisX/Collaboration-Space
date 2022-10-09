extends KinematicBody2D

export (float) var speed: float = 200.0

var velocity: Vector2 = Vector2(0.0, 0.0)

onready var participant_name: Label = $Name
onready var animation_player: AnimationPlayer = $Animation


func _ready() -> void:
	participant_name.text = "Participant"

func init(participant_dictionary: Dictionary) -> void:
	participant_name.text = participant_dictionary["name"]
	$Head.modulate = participant_dictionary["color"]
	$Arms.modulate = participant_dictionary["color"]
	$Torso.modulate = participant_dictionary["color"]
	$Legs.modulate = participant_dictionary["color"]
	$Feet.modulate = participant_dictionary["color"]
	$Hands.modulate = participant_dictionary["color"]


func _process(_delta: float) -> void:
	get_input()
	decide_animation()
	velocity = move_and_slide(velocity)


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

func decide_animation() -> void:
	if velocity.x == 0 and velocity.y > 0:
		animation_player.play("idle_s")
	elif velocity.x > 0 and velocity.y > 0:
		animation_player.play("idle_se")
	elif velocity.x > 0 and velocity.y == 0:
		animation_player.play("idle_e")
	elif velocity.x > 0 and velocity.y < 0:
		animation_player.play("idle_ne")
	elif velocity.x == 0 and velocity.y < 0:
		animation_player.play("idle_n")
	elif velocity.x < 0 and velocity.y < 0:
		animation_player.play("idle_nw")
	elif velocity.x < 0 and velocity.y == 0:
		animation_player.play("idle_w")
	elif velocity.x < 0 and velocity.y > 0:
		animation_player.play("idle_sw")





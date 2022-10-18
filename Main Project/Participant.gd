extends KinematicBody2D


export (float) var speed: float = 200.0

onready var participant_name: Label = $Name
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var sprites_m: Node2D = $SpritesM
onready var interaction_area: Area2D = $InteractionArea

var velocity: Vector2 = Vector2(0.0, 0.0)
var direction: Vector2 = Vector2(0.0, 1.0)
var current_animation: String = "idle_s"
#var id = 2023


func _ready() -> void:
	participant_name.text = "Participant"

func _process(_delta: float) -> void:
	get_input()
	decide_animation()
	animation_player.play(current_animation)
	velocity = move_and_slide(velocity)


func init(participant_dictionary: Dictionary) -> void:
	participant_name.text = participant_dictionary["Name"]
	set_selected_color()

func set_selected_color() -> void:
	sprites_m.get_node("Hair").modulate = GlobalData.participant_data["Color"]["Hair"]
	sprites_m.get_node("Eyes").modulate = GlobalData.participant_data["Color"]["Eyes"]
	sprites_m.get_node("Skin").modulate = GlobalData.participant_data["Color"]["Skin"]
	sprites_m.get_node("Shirt").modulate = GlobalData.participant_data["Color"]["Shirt"]
	sprites_m.get_node("Pants").modulate = GlobalData.participant_data["Color"]["Pants"]
	sprites_m.get_node("Shoe").modulate = GlobalData.participant_data["Color"]["Shoe"]


func get_input() -> void:
	if (Input.is_action_pressed("ui_right") or
		Input.is_action_pressed("ui_left") or
		Input.is_action_pressed("ui_down") or
		Input.is_action_pressed("ui_up")
	):
		direction = Vector2(0.0, 0.0)
	
	velocity = Vector2(0.0, 0.0)
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
		direction.x =-1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		direction.y = 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
		direction.y = -1
	velocity = velocity.normalized() * speed


func decide_animation() -> void:
	if direction.x == 0 and direction.y > 0:
		if velocity.length() == 0:
			current_animation = "idle_s"
		else:
			current_animation = "walk_s"
	elif direction.x > 0 and direction.y > 0:
		if velocity.length() == 0:
			current_animation = "idle_se"
		else:
			current_animation = "walk_se"
	elif direction.x > 0 and direction.y == 0:
		if velocity.length() == 0:
			current_animation = "idle_e"
		else:
			current_animation = "walk_e"
	elif direction.x > 0 and direction.y < 0:
		if velocity.length() == 0:
			current_animation = "idle_ne"
		else:
			current_animation = "walk_ne"
	elif direction.x == 0 and direction.y < 0:
		if velocity.length() == 0:
			current_animation = "idle_n"
		else:
			current_animation = "walk_n"
	elif direction.x < 0 and direction.y < 0:
		if velocity.length() == 0:
			current_animation = "idle_nw"
		else:
			current_animation = "walk_nw"
	elif direction.x < 0 and direction.y == 0:
		if velocity.length() == 0:
			current_animation = "idle_w"
		else:
			current_animation = "walk_w"
	elif direction.x < 0 and direction.y > 0:
		if velocity.length() == 0:
			current_animation = "idle_sw"
		else:
			current_animation = "walk_sw"





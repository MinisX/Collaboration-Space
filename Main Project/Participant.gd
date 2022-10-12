extends KinematicBody2D

export (float) var speed: float = 200.0

var velocity: Vector2 = Vector2(0.0, 0.0)

onready var participant_name: Label = $Name
onready var animation_player: AnimationPlayer = $Animation
onready var walk_animation: AnimationPlayer = $WalkAnimation
onready var idle_sprites: Node2D = $IdleSprites
onready var walk_sprites: Node2D = $WalkSprites
onready var is_moving: bool = false

func _ready() -> void:
	participant_name.text = "Participant"

func init(participant_dictionary: Dictionary) -> void:
	participant_name.text = participant_dictionary["Name"]
	set_selected_color()

func set_selected_color() -> void:
	# idle
	idle_sprites.get_node("Hair").modulate = Meeting.participant_data["Color"]["Hair"]
	idle_sprites.get_node("Eyes").modulate = Meeting.participant_data["Color"]["Eyes"]
	# skin
	idle_sprites.get_node("Head").modulate = Meeting.participant_data["Color"]["Skin"]
	idle_sprites.get_node("Hands").modulate = Meeting.participant_data["Color"]["Skin"]
	# shirt
	idle_sprites.get_node("Torso").modulate = Meeting.participant_data["Color"]["Shirt"]
	idle_sprites.get_node("Arms").modulate = Meeting.participant_data["Color"]["Shirt"]
	# 
	idle_sprites.get_node("Legs").modulate = Meeting.participant_data["Color"]["Pants"]
	idle_sprites.get_node("Feet").modulate = Meeting.participant_data["Color"]["Shoe"]
	# walk
	walk_sprites.get_node("Hair").modulate = Meeting.participant_data["Color"]["Hair"]
	walk_sprites.get_node("Eyes").modulate = Meeting.participant_data["Color"]["Eyes"]
	# skin
	walk_sprites.get_node("Head").modulate = Meeting.participant_data["Color"]["Skin"]
	walk_sprites.get_node("Hands").modulate = Meeting.participant_data["Color"]["Skin"]
	# shirt
	walk_sprites.get_node("Torso").modulate = Meeting.participant_data["Color"]["Shirt"]
	walk_sprites.get_node("Arms").modulate = Meeting.participant_data["Color"]["Shirt"]
	# 
	walk_sprites.get_node("Legs").modulate = Meeting.participant_data["Color"]["Pants"]
	walk_sprites.get_node("Feet").modulate = Meeting.participant_data["Color"]["Shoe"]


func _process(_delta: float) -> void:
	get_input()
	decide_animation()
	swap_sprites()
	velocity = move_and_slide(velocity)


func get_input() -> void:
	velocity = Vector2(0.0, 0.0)
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = velocity.normalized() * speed

func swap_sprites() -> void:
	if velocity.length() != 0.0:
		idle_sprites.hide()
		walk_sprites.show()
		is_moving = true
	else:
		idle_sprites.show()
		walk_sprites.hide()
		is_moving = false


func decide_animation() -> void:
	if velocity.x == 0 and velocity.y > 0:
		if is_moving:
			walk_animation.play("walk_s")
		else:
			animation_player.play("idle_s")
	elif velocity.x > 0 and velocity.y > 0:
		if is_moving:
			walk_animation.play("walk_se")
		else:
			animation_player.play("idle_se")
	elif velocity.x > 0 and velocity.y == 0:
		if is_moving:
			walk_animation.play("walk_e")
		else:
			animation_player.play("idle_e")
	elif velocity.x > 0 and velocity.y < 0:
		if is_moving:
			walk_animation.play("walk_ne")
		else:
			animation_player.play("idle_ne")
	elif velocity.x == 0 and velocity.y < 0:
		if is_moving:
			walk_animation.play("walk_n")
		else:
			animation_player.play("idle_n")
	elif velocity.x < 0 and velocity.y < 0:
		if is_moving:
			walk_animation.play("walk_nw")
		else:
			animation_player.play("idle_nw")
	elif velocity.x < 0 and velocity.y == 0:
		if is_moving:
			walk_animation.play("walk_w")
		else:
			animation_player.play("idle_w")
	elif velocity.x < 0 and velocity.y > 0:
		if is_moving:
			walk_animation.play("walk_sw")
		else:
			animation_player.play("idle_sw")





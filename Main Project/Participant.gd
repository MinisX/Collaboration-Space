extends KinematicBody2D


export (float) var speed: float = 200.0

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var interaction_area: Area2D = $InteractionArea
onready var location: Label = $CanvasLayer/Location
onready var participants_button:Button = $CanvasLayer/ParticipantsButton
onready var emojis_button:Button = $CanvasLayer/EmojisButton

var velocity: Vector2 = Vector2(0.0, 0.0)
var direction: Vector2 = Vector2(0.0, 1.0)
var current_animation: String = "idle_s"
var current_location: String
var participants_UI_visibility: bool = false
var emojis_UI_visibility: bool = false
var current_emoji: String = "DefaultEmoji"
var emoji_ui_active: bool = false
var dnd_activated: bool = false


# The puppet keyword means a call can be made from the network master to any network puppet.
puppet var puppet_pos: Vector2 = Vector2()
puppet var puppet_motion: Vector2 = Vector2()
puppet var puppet_current_animation: String = "idle_s"
puppet var puppet_current_location: String
puppet var puppet_emoji: String = "DefaultEmoji"

func _ready() -> void:
	print("Participant: _ready()")
	$BodyArea.connect("area_entered", self, "_get_location")
	participants_button.connect("pressed", self, "_on_participants_button_pressed")
	emojis_button.connect("pressed", self, "_on_emojis_button_pressed")
	
	$CanvasLayer/EmojiesUI.connect("emoji_pressed", self, "_get_emoji", [], 8)
	$Timer.connect("timeout", self, "_on_emoji_timeout", [], 8)

	$CanvasLayer/EmojiesUI.rect_scale = Vector2(0.0, 0.0)

	# hide participant ui if not master 
	if not is_network_master():
		$CanvasLayer/ParticipantUI.hide()
		$CanvasLayer/Location.hide()
		$CanvasLayer/EmojiesUI.hide()
		$CanvasLayer/EmojisButton.hide()


func _on_emojis_button_pressed() -> void:
	if emojis_UI_visibility == false:
		$CanvasLayer/EmojiesUI.rect_scale = Vector2(1.0, 1.0)
		emojis_UI_visibility = true
		$Timer.connect("timeout", self, "_on_emoji_timeout", [], 8)
	else:
		$CanvasLayer/EmojiesUI.rect_scale = Vector2(0.0, 0.0)
		emojis_UI_visibility = false

# Updates the puppet variable and the network master variables
func display_emoji() -> void:
	# Needed to reconnect after hiding
	if is_network_master():
		rset("puppet_emoji", current_emoji)
	else:
		current_emoji = puppet_emoji
		if current_emoji == "DefaultEmoji":
			var emojis: Array = $Emojis.get_children()
			for e in emojis:
				e.hide()
		else:
			$Emojis.get_node(current_emoji).show()

		$Timer.start()

# In order to get the current emoji
func _get_emoji(which) -> void:
	if which== "":
		which = "DefaultEmoji"
	#print("on emoji pressed signal: ", which)
	if which != "Seventeen" and which != "":
		$Emojis.get_node(which).show() # Shows emoji for Avatar
		$Timer.start()
	elif which == "Seventeen" and dnd_activated ==true:
		$Emojis.get_node(which).hide()
		puppet_emoji = "DefaultEmoji"
		dnd_activated = false
	elif which == "Seventeen" and dnd_activated == false:
		$Emojis.get_node(which).show()
		dnd_activated = true
		
	if is_network_master():
		if which != "Seventeen":
			current_emoji = which
		elif which == "Seventeen" and dnd_activated == false:
			current_emoji = "DefaultEmoji"
		elif which == "Seventeen" and dnd_activated == true:
			current_emoji = "Seventeen"


#Timer for the emoji
func _on_emoji_timeout():
	if current_emoji != "Seventeen":
		current_emoji = "DefaultEmoji"
		if is_network_master():
			rset("puppet_emoji", current_emoji)
			var emojis: Array = $Emojis.get_children()
			for e in emojis:
				e.hide()






func _process(_delta: float) -> void:
	if is_network_master():
		get_input()
		rset("puppet_motion", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_motion
	
	velocity = move_and_slide(velocity)
	
	if not is_network_master():
		puppet_pos = position
	
	decide_animation()
	animation_player.play(current_animation)
	
	display_location()
	display_emoji()
	

func _on_participants_button_pressed() -> void:
	if participants_UI_visibility ==false:
		$CanvasLayer/ParticipantsButton.hide()
		$CanvasLayer/ParticipantUI.show()
		participants_UI_visibility =true
	else:
		$CanvasLayer/ParticipantsButton.show()
		$CanvasLayer/ParticipantUI.hide()
		participants_UI_visibility =false

func display_location() -> void:
	if is_network_master():
#		current_location = area.room_name
		rset("puppet_current_location", current_location)
	else:
		current_location = puppet_current_location
	location.text = current_location
	

# Set room name to participant's location label
func _get_location(area: Area2D) -> void:
	if area.get("room_name") != null:
		if is_network_master():
			current_location = area.room_name


func set_data(new_data: Dictionary) -> void:
	$Name.text = new_data["Name"]
	set_selected_color(new_data)


func set_participant_camera(active: bool) -> void:
	$Camera.current = active


func set_selected_color(new_data: Dictionary) -> void:
	var sprite: Node2D = $SpritesM
	if new_data["Sprite"] == "female":
		sprite = $SpritesF
	elif new_data["Sprite"] == "male":
		sprite = $SpritesM
	sprite.show()
	sprite.get_node("Hair").modulate = new_data["Color"]["Hair"]
	sprite.get_node("Eyes").modulate = new_data["Color"]["Eyes"]
	sprite.get_node("Skin").modulate = new_data["Color"]["Skin"]
	sprite.get_node("Shirt").modulate = new_data["Color"]["Shirt"]
	sprite.get_node("Pants").modulate = new_data["Color"]["Pants"]
	sprite.get_node("Shoe").modulate = new_data["Color"]["Shoe"]


func get_input() -> void:
	
	if (Input.is_action_pressed("ui_right") or
		Input.is_action_pressed("ui_left") or
		Input.is_action_pressed("ui_down") or
		Input.is_action_pressed("ui_up")
	):
		direction = Vector2(0.0, 0.0)
		$CanvasLayer/ParticipantUI._test(location.text)
	
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

# Update current animation (current player direction and velocity)
# s = south, se = southeast, ...
func decide_animation() -> void:
	if is_network_master():
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
		rset("puppet_current_animation", current_animation)
	else:
		current_animation = puppet_current_animation




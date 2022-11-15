# Everything that KinematicBody2D can do, we can also do in this script. It inherits from it.
extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

# Vector is basically X and Y position combined
var velocity = Vector2.ZERO

# Set animationPlayer variabble equal to the path of AnimationPlayer node when project is initialized ( onready )
onready var animationPlayer = $AnimationPlayer
# Get access to our AnimationTree
onready var animationTree = $AnimationTree
# Get access to animation state
onready var animationState = animationTree.get("parameters/playback")

# _ means callback function
# This function gets called every time the physics update.
# This is were we are gonna move our character
func _physics_process(delta):
	# this is how we read the input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# Now we normalize the vector, so that if we move e.g right+down at the same time, 
	# it's the same speed as just e.g right
	input_vector = input_vector.normalized()
	
	# If we move, increase velocity. Otherwise stay.
	# When we are moving, animation is played
	if input_vector != Vector2.ZERO:
		# Setup our blend position only when we are moving, because we don't want to update the blend position
		# if we are not getting any input from the player. Otherwise our player will always face left
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		
		# Set the proper animation with function called travel
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# Set the proper animation with function called travel
		animationState.travel("Idle")
		# When we are moving, animation is in Idle
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta )
		
	velocity = move_and_slide(velocity)

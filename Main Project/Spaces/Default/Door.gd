extends StaticBody2D

onready var animationPlayer = $AnimationPlayer
onready var interactiveArea = $interactingArea
var open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("ui_open") and open == false:
		animationPlayer.play("open")
		open = true
	elif Input.is_action_pressed("ui_close") and open == true:
		animationPlayer.play_backwards("open")
		open = false
		


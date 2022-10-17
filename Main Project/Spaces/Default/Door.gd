extends StaticBody2D

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var interactiveArea: Area2D = $interactingArea

var open = false
var can_interact = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactiveArea.connect("body_entered", self, "_on_interaction_range_entered")
	interactiveArea.connect("body_exited", self, "_on_interaction_range_exited")

func _process(delta: float) -> void:  
	if can_interact:
		if Input.is_action_pressed("ui_open") and open == false:
			animationPlayer.play("open")
			open = true
		elif Input.is_action_pressed("ui_close") and open == true:
			animationPlayer.play_backwards("open")
			open = false
		
func _on_interaction_range_entered(body) -> void:
	if body.name == "Participant":
		can_interact = true

func _on_interaction_range_exited(body) -> void:
	if body.name == "Participant":
		can_interact = false

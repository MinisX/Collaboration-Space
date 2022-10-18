extends StaticBody2D

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var interactiveArea: Area2D = $interactingArea

export (bool) var open = false

var can_interact: bool = false
var interaction_active: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactiveArea.connect("area_entered", self, "_on_interaction_range_entered")
	interactiveArea.connect("area_exited", self, "_on_interaction_range_exited")

func _process(delta: float) -> void:  
	open()

func _on_interaction_range_entered(area) -> void:
#	if area.get_parent().id == 1234:
#		interaction_active = true
#	print(area.get_parent().id)
	interaction_active = true

func _on_interaction_range_exited(area) -> void:
	interaction_active = false

func open() -> void:
	if Input.is_action_just_pressed("ui_select") and interaction_active:
		if open:
			animationPlayer.play_backwards("open")
			open = false
		else:
			animationPlayer.play("open")
			open = true





extends StaticBody2D

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var interactiveArea: Area2D = $interactingArea

export (bool) var open = false

var can_interact: bool = false
var interaction_active: bool = false


# Open and close the door
remotesync func interact():
	print("Door: open_door")
	if open:
		animationPlayer.play_backwards("open")
		open = false
	else:
		animationPlayer.play("open")
		open = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactiveArea.connect("area_entered", self, "_on_interaction_range_entered")
	interactiveArea.connect("area_exited", self, "_on_interaction_range_exited")


func _process(delta: float) -> void:  
#	open()
	if Input.is_action_just_pressed("ui_open") and interaction_active:
		rpc("interact")


func _on_interaction_range_entered(area: Area2D) -> void: 
	if (area.get_parent().get("speed") != null and 
		str(get_tree().get_network_unique_id()) == area.get_parent().name):
		interaction_active = true
		


func _on_interaction_range_exited(area: Area2D) -> void:
	if (area.get_parent().get("speed") != null and 
		str(get_tree().get_network_unique_id()) == area.get_parent().name):
		interaction_active = false






extends StaticBody2D

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var interactiveArea: Area2D = $interactingArea

var open = false

puppet var puppet_open = false

var can_interact: bool = false
var interaction_active: bool = false

var active_rotation = 0


func update_state() -> void:
	if Meeting.is_network_master():
		rset("puppet_open", open)
	else:
		open = puppet_open


# Open and close the door
remotesync func interact():
	print("Door: open_door")
	if open:
		open = false
	else:
		open = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactiveArea.connect("area_entered", self, "_on_interaction_range_entered")
	interactiveArea.connect("area_exited", self, "_on_interaction_range_exited")
	# todo test if this is needed in this version
	Meeting.connect("connection_succeeded", self, "update_state")
	active_rotation = self.rotation_degrees

func _process(delta: float) -> void:  
	update_state()
	
	if Input.is_action_just_pressed("ui_open") and interaction_active:
		rpc("interact")
	
	if open:
#		self.hide()
		self.rotation_degrees = active_rotation - 90
#		get_node("CollisionShape2D").disabled = true
	else:
		self.rotation_degrees = active_rotation
#		self.show()
#		get_node("CollisionShape2D").disabled = false


func _on_interaction_range_entered(area: Area2D) -> void: 
	if (area.get_parent().get("speed") != null and 
		str(get_tree().get_network_unique_id()) == area.get_parent().name):
		interaction_active = true


func _on_interaction_range_exited(area: Area2D) -> void:
	if (area.get_parent().get("speed") != null and 
		str(get_tree().get_network_unique_id()) == area.get_parent().name):
		interaction_active = false





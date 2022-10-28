extends Control


onready var thu_online_p: Label = $VBoxContainer/HBoxContainer/THU/OnlineParticipants
onready var library_online_p: Label = $VBoxContainer/HBoxContainer/Library/OnlineParticipants
onready var office_online_p: Label = $VBoxContainer/HBoxContainer/Office/OnlineParticipants

onready var button_group: ButtonGroup = null
onready var join_button: Button = $VBoxContainer/CenterContainer/JoinButton

#var selected_map_name: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_group = $VBoxContainer/HBoxContainer/THU/THUMap.group
	button_group.connect("pressed", self, "_on_map_selected")
	join_button.connect("pressed", self, "_on_join_pressed")
	
# Called when a button in a button group is selected
func _on_map_selected(selected: TextureButton) -> void:
#	selected_map_name = selected.name
	pass

# Called when join button is pressed
func _on_join_pressed() -> void:
#	print(selected_map_name)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

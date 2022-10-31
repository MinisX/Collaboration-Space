extends Control


onready var thu_online_p: Label = $VBoxContainer/HBoxContainer/THU/OnlineParticipants
onready var library_online_p: Label = $VBoxContainer/HBoxContainer/Library/OnlineParticipants
onready var office_online_p: Label = $VBoxContainer/HBoxContainer/Office/OnlineParticipants
onready var button_group: ButtonGroup = null
onready var join_button: Button = $VBoxContainer/CenterContainer/JoinButton



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	button_group = $VBoxContainer/HBoxContainer/THU/University.group
	button_group.connect("pressed", self, "_on_map_selected")
	join_button.connect("pressed", self, "_on_join_pressed")

	
# Called when a button in a button group is selected
func _on_map_selected(selected: TextureButton) -> void:
	print("SelectSpace: selected space: ", selected.name)
	Meeting.selected_space = selected.name


# Called when join button is pressed
func _on_join_pressed() -> void:
	self.hide()

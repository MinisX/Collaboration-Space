extends Control


onready var thu_online_p: Label = $VBoxContainer/HBoxContainer/THU/OnlineParticipants
onready var library_online_p: Label = $VBoxContainer/HBoxContainer/Library/OnlineParticipants
onready var office_online_p: Label = $VBoxContainer/HBoxContainer/Office/OnlineParticipants
onready var button_group: ButtonGroup = null
onready var join_button: Button = $VBoxContainer/CenterContainer/JoinButton

onready var spaces : = {
	"Library": {},
	"Office": {},
	"University": {},
}

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	button_group = $VBoxContainer/HBoxContainer/THU/University.group
	button_group.connect("pressed", self, "_on_map_selected")
	join_button.connect("pressed", self, "_on_join_pressed")
		
func _draw() -> void:
	if !Meeting.is_server:
		set_online()

func set_online() -> void:
	Firebase.get_document("spaces/online", http)

func set_port(selected_space_name: String) -> void:
	if selected_space_name == "University":
		Meeting.DEFAULT_PORT = 1235
	elif selected_space_name == "Library":
		Meeting.DEFAULT_PORT = 1236
	elif selected_space_name == "Office":
		Meeting.DEFAULT_PORT = 1237

# Called when a button in a button group is selected
func _on_map_selected(selected: TextureButton) -> void:
	print("SelectSpace: selected space: ", selected.name)
	Meeting.participant_data["selected_space"] = selected.name
	set_port(selected.name)

# Called when join button is pressed
func _on_join_pressed() -> void:
	self.hide()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if response_code == 200:
		print("SelectSpace.gd: online fetched succesfully")
		self.spaces = result_body.fields
		
		var library_online = spaces.Library["stringValue"]
		var office_online = spaces.Office["stringValue"]
		var university_online = spaces.University["stringValue"]
		
		library_online_p.set_text(library_online + " online")
		office_online_p.set_text(office_online + " online")
		thu_online_p.set_text(university_online + " online") 
	else:
		print("SelectSpace.gd: online NOT fetched")

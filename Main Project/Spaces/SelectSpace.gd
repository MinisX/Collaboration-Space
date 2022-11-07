extends Control


onready var thu_online_p: Label = $VBoxContainer/HBoxContainer/THU/OnlineParticipants
onready var library_online_p: Label = $VBoxContainer/HBoxContainer/Library/OnlineParticipants
onready var office_online_p: Label = $VBoxContainer/HBoxContainer/Office/OnlineParticipants
onready var button_group: ButtonGroup = null
onready var join_button: Button = $VBoxContainer/CenterContainer/JoinButton

onready var spaces : = {
	"players_online": {},
}

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest

# This variable counts the amount of HTTP responses/requests
onready var http_responses_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	button_group = $VBoxContainer/HBoxContainer/THU/University.group
	button_group.connect("pressed", self, "_on_map_selected")
	join_button.connect("pressed", self, "_on_join_pressed")
	
	set_online()

func set_online() -> void:
	Firebase.get_document("spaces/Library", http)

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
	http_responses_count += 1
	
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if response_code == 200:
		print("SelectSpace.gd: online fetched succesfully")
		self.spaces = result_body.fields
		
		if http_responses_count == 1:
			var library_online = spaces.players_online["stringValue"]
			library_online_p.set_text(library_online + " online")
			Firebase.get_document("spaces/Office", http)
		elif http_responses_count == 2:
			var office_online = spaces.players_online["stringValue"]
			office_online_p.set_text(office_online + " online")
			Firebase.get_document("spaces/University", http)
		elif http_responses_count == 3:
			var university_online = spaces.players_online["stringValue"]
			thu_online_p.set_text(university_online + " online") 
	else:
		print("SelectSpace.gd: online NOT fetched")

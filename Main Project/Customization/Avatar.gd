extends Control

onready var sprites: Control = $Sprites
onready var animation: AnimationPlayer = $Animation
onready var button_group: ButtonGroup = null
onready var color_picker: ColorPicker = $ColorPicker
onready var turn_avatar_slider: HSlider = $MarginContainer/VBoxContainer/TurnAvatarSlider
onready var ok_button: Button = $Ok
onready var name_input: LineEdit = $NameInput

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest

# Information needed for saving the data to Firestore
var new_profile := false
var information_sent := false
var profile : = {
	"name": {},
	"hair": {},
	"eyes": {},
	"legs": {},
	"feet": {},
	"hands": {},
	"head": {},
	"torso": {},
	"arms": {}
} setget set_profile

var active_part: String = "Skin"
var active_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	button_group = $MarginContainer/VBoxContainer/Hair.group
	button_group.connect("pressed", self, "_on_avatar_part_selected")
	color_picker.connect("color_changed", self, "_on_color_value_changed")
	turn_avatar_slider.connect("value_changed", self, "_on_avatar_turned")
	ok_button.connect("pressed", self, "_on_ok_pressed")
#	color_picker.connect("popup_closed", self, "_on_color_selected")
	
	# Try to access the document from Firestore. This is needed for HTTP request to understand
	# If it's new user or existing user
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	
# Here we receive HTTP response from Firestore. First when accesing the document
# and second time when saving it
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		# If response code is 404 it means that we have new user, document does not exist yet
		404:
			print("HTTP Response: Code 404 -> New user")
			new_profile = true
			return
		# If response code is 200 it means that the document exists in the DB, so we saved it succesfully
		200:
			if information_sent:
				print("HTTP Response: Code 200 -> Information saved")
				#notification.text = ""
				information_sent = false
				get_tree().change_scene("res://Spaces/Default/Lobby.tscn")
			self.profile = result_body.fields

func _on_ok_pressed() -> void:
	Meeting.participant_data["Name"] = name_input.text
	
	# Pushing data to Firestore
	convert_data_for_firebase()
	match new_profile:
		true:
			print("true")
			Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)
		false: 
			print("false")
			Firebase.update_document("users/%s" % Firebase.user_info.id, profile, http)
			
	information_sent = true
	
	#get_tree().change_scene("res://Spaces/Default/Default.tscn")

# This method converts the user data to the format we need for Firestore
func convert_data_for_firebase() -> void:
	profile.name = { "stringValue": Meeting.participant_data["Name"]}
	profile.hair = { "stringValue": Meeting.participant_data["Color"]["Hair"].to_html()}
	profile.eyes = { "stringValue": Meeting.participant_data["Color"]["Eyes"].to_html()}
	profile.legs = { "stringValue": Meeting.participant_data["Color"]["Pants"].to_html()}
	profile.feet = { "stringValue": Meeting.participant_data["Color"]["Shoe"].to_html()}
	profile.hands = { "stringValue": Meeting.participant_data["Color"]["Skin"].to_html()}
	profile.head = { "stringValue": Meeting.participant_data["Color"]["Skin"].to_html()}
	profile.torso = { "stringValue": Meeting.participant_data["Color"]["Shirt"].to_html()}
	profile.arms = { "stringValue": Meeting.participant_data["Color"]["Shirt"].to_html()}

# This is setter and getter function for our profile dictionary	
func set_profile(value: Dictionary) -> void:
	profile = value

func _on_color_value_changed(color: Color) -> void:
	active_color = color
	Meeting.participant_data["Color"][active_part] = active_color
	set_selected_color()


func _on_avatar_turned(value: int) -> void:
	if value == 0:
		animation.play("idle_s")
	elif value == 1:
		animation.play("idle_se")
	elif value == 2:
		animation.play("idle_e")
	elif value == 3:
		animation.play("idle_ne")
	elif value == 4:
		animation.play("idle_n")
	elif value == 5:
		animation.play("idle_nw")
	elif value == 6:
		animation.play("idle_w")
	elif value == 7:
		animation.play("idle_sw")


func _on_avatar_part_selected(selected: Button) -> void:
	active_part = selected.name


func set_selected_color() -> void:
	sprites.get_node("Hair").modulate = Meeting.participant_data["Color"]["Hair"]
	sprites.get_node("Eyes").modulate = Meeting.participant_data["Color"]["Eyes"]
	sprites.get_node("Legs").modulate = Meeting.participant_data["Color"]["Pants"]
	sprites.get_node("Feet").modulate = Meeting.participant_data["Color"]["Shoe"]
	# skin
	sprites.get_node("Hands").modulate = Meeting.participant_data["Color"]["Skin"]
	sprites.get_node("Head").modulate = Meeting.participant_data["Color"]["Skin"]
	# shirt
	sprites.get_node("Torso").modulate = Meeting.participant_data["Color"]["Shirt"]
	sprites.get_node("Arms").modulate = Meeting.participant_data["Color"]["Shirt"]
	

func _on_color_selected() -> void:
	pass
#	Meeting.participant_data["color"][active_part] = active_color
#	set_selected_color()

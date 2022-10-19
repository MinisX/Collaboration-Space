extends Control

onready var sprites: Control = $Sprites
onready var animation: AnimationPlayer = $Animation
onready var button_group: ButtonGroup = null
onready var color_picker: ColorPicker = $ColorPicker
onready var turn_avatar_slider: HSlider = $MarginContainer/VBoxContainer/TurnAvatarSlider
onready var ok_button: Button = $Ok
onready var name_input: LineEdit = $NameInput
onready var http : HTTPRequest = $HTTPRequest
onready var notification : Label = $Container/Notification

var active_part: String = "Skin"
var active_color: Color = Color(1.0, 1.0, 1.0, 1.0)

var new_profile := false
var information_sent := false
var profile : = {
	"hair": {},
	"eyes": {},
	"legs": {},
	"feet": {},
	"hands": {},
	"head": {},
	"torso": {},
	"arms": {}
}



func _ready() -> void:
	button_group = $MarginContainer/VBoxContainer/Hair.group
	button_group.connect("pressed", self, "_on_avatar_part_selected")
	color_picker.connect("color_changed", self, "_on_color_value_changed")
	turn_avatar_slider.connect("value_changed", self, "_on_avatar_turned")
	ok_button.connect("pressed", self, "_on_ok_pressed")
#	color_picker.connect("popup_closed", self, "_on_color_selected")
	Firebase.get_document("users/%s" % Firebase.user_info.id, http) 

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	match response_code:
		404:
			#notification.text = ""
			new_profile = true
		200:
			if information_sent:
				#notification.text = ""
				information_sent = false
			self.profile = result_body.fields	
		

func _on_ok_pressed() -> void:
	print("Avatar: _on_ok_pressed()")
	#GlobalData.participant_data["Name"] = name_input.text
	
	profile.hair = { "intergerValue": GlobalData.participant_data["Color"]["Hair"]}
	profile.eyes = { "intergerValue": GlobalData.participant_data["Color"]["Eyes"]}
	profile.legs = { "intergerValue": GlobalData.participant_data["Color"]["Pants"]}
	profile.feet = { "intergerValue": GlobalData.participant_data["Color"]["Shoe"]}
	profile.hands = { "intergerValue": GlobalData.participant_data["Color"]["Skin"]}
	profile.head = { "intergerValue": GlobalData.participant_data["Color"]["Skin"]}
	profile.torso = { "intergerValue": GlobalData.participant_data["Color"]["Shirt"]}
	profile.arms = { "intergerValue": GlobalData.participant_data["Color"]["Shirt"]}
	
	print(profile)
	Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)
	match new_profile:
		true:
			print("true")
			Firebase.save_document("users?documentId=%s" % Firebase.user_info.id, profile, http)
		false: 
			print("false")
			Firebase.update_document("users/%s" % Firebase.user_info.id, profile, http)
	
	#get_tree().change_scene("res://Spaces/Default/Lobby.tscn")
	
	#get_tree().change_scene("res://Spaces/Default/Default.tscn")


func _on_color_value_changed(color: Color) -> void:
	active_color = color
	GlobalData.participant_data["Color"][active_part] = active_color
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
	sprites.get_node("Hair").modulate = GlobalData.participant_data["Color"]["Hair"]
	sprites.get_node("Eyes").modulate = GlobalData.participant_data["Color"]["Eyes"]
	sprites.get_node("Legs").modulate = GlobalData.participant_data["Color"]["Pants"]
	sprites.get_node("Feet").modulate = GlobalData.participant_data["Color"]["Shoe"]
	# skin
	sprites.get_node("Hands").modulate = GlobalData.participant_data["Color"]["Skin"]
	sprites.get_node("Head").modulate = GlobalData.participant_data["Color"]["Skin"]
	# shirt
	sprites.get_node("Torso").modulate = GlobalData.participant_data["Color"]["Shirt"]
	sprites.get_node("Arms").modulate = GlobalData.participant_data["Color"]["Shirt"]
	

func _on_color_selected() -> void:
	pass
#	Meeting.participant_data["color"][active_part] = active_color
#	set_selected_color()

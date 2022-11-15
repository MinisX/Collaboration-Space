extends Control




onready var sprites: Control = $Sprites
onready var animation: AnimationPlayer = $Animation
onready var button_group: ButtonGroup = null
onready var color_picker: ColorPicker = $ColorPicker
onready var turn_avatar_slider: HSlider = $MarginContainer/VBoxContainer/TurnAvatarSlider
onready var ok_button: Button = $Ok
onready var name_input: LineEdit = $NameInput

var active_part: String = "Skin"
var active_color: Color = Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
	button_group = $MarginContainer/VBoxContainer/Hair.group
	button_group.connect("pressed", self, "_on_avatar_part_selected")
	color_picker.connect("color_changed", self, "_on_color_value_changed")
	turn_avatar_slider.connect("value_changed", self, "_on_avatar_turned")
	ok_button.connect("pressed", self, "_on_ok_pressed")
#	color_picker.connect("popup_closed", self, "_on_color_selected")

func _on_ok_pressed() -> void:
	Meeting.participant_data["Name"] = name_input.text
	get_tree().change_scene("res://Spaces/Default/Default.tscn")


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

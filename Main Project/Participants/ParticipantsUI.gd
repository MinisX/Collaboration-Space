extends Control

onready var participants_ok_button = $HideButton
onready var participants_list_view: ItemList = $ItemList

func _ready():
	participants_ok_button.connect("pressed", self, "_on_participants_ok_button_pressed")


func _draw():
	print("in draw")
	var participants = Meeting.get_participant_list()
	participants.sort()
	participants_list_view.clear()
	participants_list_view.add_item(Meeting.get_participant_name() + " (You)")
	for p in participants:
		participants_list_view.add_item(p["Name"])

func _on_participants_ok_button_pressed() -> void:
	self.hide()

extends Control

onready var http : HTTPRequest = $HTTPRequest
# Here we get the access to the fields of the userprofile screen
onready var nickname : LineEdit = $Container/VBoxContainer2/Name/LineEdit
onready var character_class : LineEdit = $Container/VBoxContainer2/Class/LineEdit
onready var notification : Label = $Container/Notification
onready var strength : Slider = $Container/VBoxContainer2/Strength/Slider
onready var intelligence : Slider = $Container/VBoxContainer2/Intelligence/Slider
onready var dexterity : Slider = $Container/VBoxContainer2/Dexterity/Slider

# Flags if profile is new ( create or update ) and if information is sent or retrieved
var new_profile := false
var information_sent := false

# At the end of the dictionary we create a setter and getter for our profile
var profile := {
	"nickname": {},
	"character_class": {},
	"strength": {},
	"intelligence": {},
	"dexterity": {}
} setget set_profile

# As soon as user enter the UserProfile scene, this function will be execute
func _ready() -> void:
	# We try to get the document containing his information
	Firebase.get_document("users/%s" % Firebase.user_info.id, http)
	print("_readyUserProfile")

func _on_HTTPRequest_request_completed(result, response_code, headers, body) -> void:
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	# Based on the HTTP response code we perform actions
	print(response_code)
	match response_code:
		404:
			notification.text = "Please, enter your information"
			new_profile = true
			return
		200:
			if information_sent:
				notification.text = "Information saved succusfully"
				information_sent = false
			# Set profile equaled to the result_body
			self.profile = result_body.fields


func _on_ConfirmButton_pressed() -> void:
	print("here1")
	# Perform validation and checking of the user information
	if nickname.text.empty() or character_class.text.empty():
		notification.text = "Please, enter your nickname and class"
		return
	# If everything is ok, we set our profile dictionary be equaled to the input information
	# Each field of our dictionary is another dictionary pair <"valueType" : fieldValue>
	profile.nickname = { "stringValue": nickname.text}
	profile.character_class = { "stringValue" : character_class.text }
	profile.strength = { "integerValue" : strength.value }
	profile.intelligence = { "integerValue" : intelligence.value }
	profile.dexterity = { "integerValue" : dexterity.value }
	# Check if this is a new profile
	match new_profile:
		# If profile is new, create new document
		true: 
			
			
			var testData := {
			"nickname": {}
			}
		
			testData.nickname = { "stringValue": "test3"}
		
			print("here2")
			Firebase.save_document("test?documentId=%s" % Firebase.user_info.id, testData, http)
		false:
			# If this is existing profile, then we just update it
			Firebase.update_document("users/%s" % Firebase.user_info.id, profile,http)
			print("here3")
	# Check status of our flag
	information_sent = true
	print("here4")

# We want to update the values of our control nodes whenever we use this setter ( e.g on line 43, self.profile = ... )
func set_profile(value: Dictionary) -> void:
	profile = value
	nickname.text = profile.nickname.stringValue
	character_class.text = profile.character_class.stringValue
	strength.value = int(profile.strength.integerValue)
	intelligence.value = int(profile.dexterity.integerValue)

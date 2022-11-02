extends Control

# Access HTTPRequest instance
onready var http : HTTPRequest = $HTTPRequest
onready var http_responses_count = 0

func _ready()-> void:
	exit_meeting()
		
func exit_meeting() -> void:
	print("Exit_Meeting: exit_meeting()")
	Firebase.delete_document("users/%s" % Firebase.user_info.id, http)

# This is response from HTTP request when closing the window
# If user is anon, it's deleted. If registered, just logged off
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	http_responses_count += 1
	var result_body := JSON.parse(body.get_string_from_ascii()).result as Dictionary
	
	if http_responses_count == 1:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User data deleted from DB, requesting delete of user account")
			Firebase.delete_account(http)
		else:
			print("\nHTTP Response: %s -> User data was not deleted" % response_code)
			
	if http_responses_count == 2:
		if response_code == 200:
			print("\nHTTP Response: Code 200 -> User account was deleted")
			Firebase.user_info = {}
			print("Exit_Meeting: get_tree().quit()")
			get_tree().quit()
		else:
			print("\nHTTP Response: %s -> User account not deleted" % response_code)

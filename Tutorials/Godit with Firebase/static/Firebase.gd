extends Node

const API_KEY := "AIzaSyAEtLCIGwT4jbZdjcrwx9mqE9eI7lMcrKg"

# These are URLs (endpoints) for HTTP POST request to Firebase
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY

# This toke tells us that the user has been logged in. Later we will 
# use this to make request on behalf of user who has logged in
var current_token := ""

# To get the token above we will use this function
# We are passing to it result which is the response that we have got from Firebase
# Then we parse it as a dictionary as we get it as Array
# And then we return our idToken as String
func _get_token_id_from_result(result: Array) -> String:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return result_body.idToken

# As input we take email and password and third parameter it HTTPRequiest
func register(email: String, password: String, http: HTTPRequest) -> void:
	# Body of our HTTP request which we will send to Firebase server
	var body := {
		"email": email,
		"password": password,
	}
	
	# We convert our body to JSON format and send it to the Firebase server and wait for response
	# First parameter is the request we want to send
	# Second parameter is our headers, which we don't use for now
	# Third parameter is if we want to use SSL or not. False = we don't use it
	# The rest parameters are clear
	http.request(REGISTER_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	# When the response is received from Firebase, it's stored in variable "result"
	var result := yield(http, "request_completed") as Array
	# If our response is OK ( 200 ), we store the token
	if result[1] == 200:
		current_token = _get_token_id_from_result(result)
	
func login(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		"email": email,
		"password": password,
	}
	
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))

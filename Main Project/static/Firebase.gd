extends Node

const API_KEY := "AIzaSyAqfWoeATjX6HdszzzsbbNSrFELNkWodNg"
const PROJECT_ID := "collaboration-space-2d"

# These are URLs (endpoints) for HTTP POST request to Firebase
const REGISTER_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const LOGIN_URL := "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
const ANON_LOGIN_URL:= "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
const FIRESTORE_URL := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_ID

# In user_info dictionary we store user token and user id
# The token tells us that the user has been logged in. Later we will 
# use this to make request on behalf of user who has logged in
var user_info := {}

# To get the token above we will use this function
# We are passing to it result which is the response that we have got from Firebase
# Then we parse it as a dictionary as we get it as Array
# And then we return our idToken and user id as Dictionary
func _get_user_info(result: Array) -> Dictionary:
	var result_body := JSON.parse(result[3].get_string_from_ascii()).result as Dictionary
	return {
		"token": result_body.idToken,
		"id": result_body.localId
	}

# Since we want to authenticate our users when they are making a request, we have to use 
# these headers to tell our server that user is authenticated.
func _get_request_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_info.token
	])

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
	# If our response is OK ( 200 ), we store user information
	if result[1] == 200:
		user_info = _get_user_info(result)
	
func anon_login(http: HTTPRequest) -> void:
	print("anon_login_start")
	var body := {
		"returnSecureToken": true
	}
	
	http.request(ANON_LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	# When the response is received from Firebase, it's stored in variable "result"
	var result := yield(http, "request_completed") as Array
	# If our response is OK ( 200 ), we store user information
	if result[1] == 200:
		print("anon_login_success")
		user_info = _get_user_info(result)
	
func login(email: String, password: String, http: HTTPRequest) -> void:
	var body := {
		"email": email,
		"password": password,
		"returnSecureToken": true
	}
	
	http.request(LOGIN_URL, [], false, HTTPClient.METHOD_POST, to_json(body))
	# When the response is received from Firebase, it's stored in variable "result"
	var result := yield(http, "request_completed") as Array
	# If our response is OK ( 200 ), we store user information
	if result[1] == 200:
		user_info = _get_user_info(result)

# Function to create a new document
# Path parameter is the path to the ducument
# Field a new document is going to have
func save_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	# Make the request to create the document
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_POST, body)
	
# Function to get existing document
func get_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_GET)
	
# Function to update existing document
func update_document(path: String, fields: Dictionary, http: HTTPRequest) -> void:
	var document := { "fields": fields }
	var body := to_json(document)
	var url := FIRESTORE_URL + path
	# Make the request to update the existing document
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_PATCH, body)
	
# Function to delete existing document	
func delete_document(path: String, http: HTTPRequest) -> void:
	var url := FIRESTORE_URL + path
	# Make the request to DELETE the existing document
	http.request(url, _get_request_headers(), false, HTTPClient.METHOD_DELETE)

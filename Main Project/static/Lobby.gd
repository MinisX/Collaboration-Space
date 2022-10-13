extends Node

# Confriration parameters
const DEFAULT_PORT: int = 4242
const MAX_PARTICIPANT: int = 30
const SERVER_IP: String = "34.159.28.32"

# Names for remote participants in id:name format.
var participants: Dictionary = {}
var participants_ready: Array = []

	
func test() -> void:
	Server.host_meeting()
	print("test")
	
# Return participants
func get_participant_list() -> Array:
	return participants.values()
	
func add_participant_into_list(userID : int) -> void:
	var id: int = get_tree().get_rpc_sender_id()
	#participants[id] = new_participant_name
	emit_signal("participants_list_changed")

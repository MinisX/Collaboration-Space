extends Node2D

# This is the main scene of the app.
# The scene is changed to Lobby or Login according to the presence of "--server" arguemnt
# Therefore we don't need separate server code  
func _ready():
	print("Main: main.gd")
	if "--server" in OS.get_cmdline_args():
		Meeting.is_server = true
		get_tree().change_scene("res://Spaces/Default/Lobby.tscn")
		print("Main: change scene to server")
	else:
		get_tree().change_scene("res://login/LoginScreen.tscn")
		print("Main: change scene to client")


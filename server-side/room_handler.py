import json
import jsonhelper

room1 = set()
room2 = set()
room3 = set()

def add_user_to_room(ws, participant_data):
    is_in_room(ws, participant_data, "room_1", room1)
    is_in_room(ws, participant_data, "room_2", room2)
    is_in_room(ws, participant_data, "room_3", room3)

def is_in_room(ws, participant_data, room_name, room):
    if participant_data["room"] == room_name:
        if participant_data["state"] == "join" and not ws in room:
            room.add(ws)
        elif participant_data["state"] == "depart" and ws in room:
            room.remove(ws)
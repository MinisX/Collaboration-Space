room1 = dict()
room2 = dict()
library = dict()

rooms = {"room_1": room1, "room_2": room2, "Library": library}

def manage_user_in_rooms(websocket, data):
    if data is not None:
            print("user_id: ", data["user_id"])
            print("websocket.id: ", websocket.id)
            # If data is JSON then manage user add/del in room
            if data["user_id"] == websocket.id:
                # Add user to corresponding room
                if data["state"] == "join":
                    for room in rooms: 
                        if data["room"] == room:
                            rooms[room][data["user_id"]] = room
                            print("roomsets after addition: ", rooms[room])
                # Delete user from room
                elif data["state"] == "depart":
                    for room in rooms: 
                        if data["room"] == room:
                            if data["user_id"] in rooms[room]:
                                print("room before deletion: ", room)
                                rooms[room].pop(data["user_id"])
                                print("room after deletion: ", room)
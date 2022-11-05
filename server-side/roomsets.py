import dbhandler

room1 = dict()
room2 = dict()
library = dict()

rooms = {"room_1": room1, "room_2": room2, "Library": library}

async def manage_user_in_rooms(websocket, data):
    if "user_id" in data and "state" in data:
            # If data is JSON then manage user add/del in room
            if data["user_id"] == websocket.id:
                # Add user to corresponding room
                if data["state"] == "join":
                    await dbhandler.send_retrieve_message(websocket, data["room"], data["user_id"])
                    for room in rooms: 
                        if data["room"] == room:
                            rooms[room][data["user_id"]] = room
                # Delete user from room
                elif data["state"] == "depart":
                    for room in rooms: 
                        if data["room"] == room:
                            if data["user_id"] in rooms[room]:
                                rooms[room].pop(data["user_id"])
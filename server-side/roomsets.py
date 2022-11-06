import dbhandler

room1, room2, library, aula, b_building, b_building_learning, Cafeteria, cafeteria_outside, \
    physics_1, physics_2, c_building, c_room, c_chill, c_12, c_10, c_printer, d_building, \
        a_building, a_room_1, a_room_2, outside_main_1, outside_main_2, outside_main_3, \
            outside_aula_left, inside_out = dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), \
            dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict()

rooms = {"room_1": room1, "room_2": room2, "Library": library, "Aula": aula, "B Building": b_building,
        "B Building Learning": b_building_learning, "Cafeteria": Cafeteria, "Cafeteria Outside": cafeteria_outside,
        "physics_1": physics_1, "Physics 2": physics_2, "C": c_building, "C Room": c_room,
        "C Chill": c_chill, "C 12": c_12, "C 11": c_10, "C Printer": c_printer, "D": d_building, 
        "A": a_building, "A Room 1": a_room_1, "A Room 2": a_room_2, "Outside Main 1": outside_main_1,
        "Outside Main 2": outside_main_2, "Outside Main 3": outside_main_3, 
        "Outside Aula Left": outside_aula_left, "Inside Out": inside_out}

async def manage_user_in_rooms(websocket, data):
    if "user_id" in data and "state" in data:
            # If data is JSON then manage user add/del in room
            if data["user_id"] == websocket.id:
                # Add user to corresponding room
                if data["state"] == "join":
                    await dbhandler.send_retrieve_message(websocket, data["room"].replace(" ", "_"), data["user_id"])
                    for room in rooms: 
                        if data["room"] == room:
                            rooms[room][data["user_id"]] = room
                # Delete user from room
                elif data["state"] == "depart":
                    for room in rooms: 
                        if data["room"] == room:
                            if data["user_id"] in rooms[room]:
                                rooms[room].pop(data["user_id"])
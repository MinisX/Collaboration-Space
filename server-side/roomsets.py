import dbhandler

room1, room2, library, aula, b_building, b_building_learning, Cafeteria, cafeteria_outside, \
    physics_1, physics_2, c_building, c_room, c_chill, c_12, c_10, c_printer, d_building, \
        a_building, a_room_1, a_room_2, outside_main_1, outside_main_2, outside_main_3, \
            outside_aula_left, inside_out, shared_office_room, personal_office_1, personal_office_2, \
                personal_office_3, meeting_room, reception, corridor_1, corridor_2, corridor_3, \
                    corridor_4, corridor_5 = dict(), dict(), dict(), dict(), dict(), dict(), dict(), \
                     dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), \
                        dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), \
                        dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict(), dict()

rooms = {"room_1": room1, "room_2": room2, "Library": library, "Aula": aula, "B Building": b_building,
        "B Building Learning": b_building_learning, "Cafeteria": Cafeteria, "Cafeteria Outside": cafeteria_outside,
        "physics_1": physics_1, "Physics 2": physics_2, "C": c_building, "C Room": c_room,
        "C Chill": c_chill, "C 12": c_12, "C 11": c_10, "C Printer": c_printer, "D": d_building, 
        "A": a_building, "A Room 1": a_room_1, "A Room 2": a_room_2, "Outside Main 1": outside_main_1,
        "Outside Main 2": outside_main_2, "Outside Main 3": outside_main_3, 
        "Outside Aula Left": outside_aula_left, "Inside Out": inside_out, "shared_office_room": shared_office_room,
        "personal_office_1": personal_office_1, "personal_office_2": personal_office_2, 
        "personal_office_3": personal_office_3, "meeting_room": meeting_room, "reception": reception,
        "corridor_1": corridor_1, "corridor_2": corridor_2, "corridor_3": corridor_3, 
        "corridor_4": corridor_4, "corridor_5": corridor_5}

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
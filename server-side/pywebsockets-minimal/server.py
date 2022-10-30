#!/usr/bin/env python

import asyncio
import json
import websockets
import roomsets

CONNECTIONS = dict()

async def hello(websocket):
    msg = await websocket.recv()
    data = is_json(msg)
    print(data)
    if data is not None:
        if "register_id" in data:
            websocket.id = data["user_id"]
            CONNECTIONS[websocket.id] = websocket
            print(CONNECTIONS)
    async for msg in websocket:
        data = is_json(msg)
        print("Room data: ")
        print(data)
        if data is not None:
            print("user_id: ")
            print(data["user_id"])
            print("websocket.id: ")
            print(websocket.id)
            # If data is JSON then manage user add/del in room
            if data["user_id"] == websocket.id:
                # Add user to corresponding room
                if data["state"] == "join":
                    for room in roomsets.rooms: 
                        if data["room"] == room:
                            roomsets.rooms[room][data["user_id"]] = room
                            print("roomsets after addition: ")
                            print(roomsets.rooms[room])
                # Delete user from room
                elif data["state"] == "depart":
                    for room in roomsets.rooms.values():
                        if data["user_id"] in room:
                            del room[data["user_id"]]
                            print("roomsets after deletion: ")
                            print(room)
        # Else send to users in the same room
        else:
            for room in roomsets.rooms.values():
                if websocket.id in room:
                    for client in room:
                        if websocket.id != client:
                            await CONNECTIONS[client].send(msg)               

def is_json(msg):
    try:
        data = json.loads(msg)
    except Exception as e:
        return None
    return data

async def main():
    async with websockets.serve(hello, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever

asyncio.run(main())

#!/usr/bin/env python

import asyncio
import signal
import websockets
import dbhandler
import roomsets
import jsonhelper

CONNECTIONS = dict()
NAMES = dict()
ROOMS = dict()

# process messages
async def process_message(websocket):
    msg = await websocket.recv()
    data = jsonhelper.parse_json(msg)
    # Register user id when they first log in
    if data is not None and data["type"] == "register":
        register_user(websocket, data)
    async for msg in websocket:
        data = jsonhelper.parse_json(msg)
        # Manage rooms of users
        if data is not None and data["type"] == "assign_room":
            await roomsets.manage_user_in_rooms(websocket, data)
        # Else send to users in the same room
        elif data is not None and data["type"] == "message":
            await send_store_msg(websocket, data)

# Send message to other clients
async def send_store_msg(websocket, data):
    if websocket.id in NAMES and "msg" in data:
        new_msg = "{\"type\": \"message\", \"name\": \"" + NAMES[websocket.id] + "\", \"msg\": \"" + data["msg"] + "\"}"
        receivers = list()
        room_name = None
        for room in roomsets.rooms:
            if websocket.id in roomsets.rooms[room]:
                room_name = room
                for client in roomsets.rooms[room]:
                    if websocket.id != client:
                        # Add all users in the same room as receivers
                        receivers.append(client)
                        await CONNECTIONS[client].send(new_msg)
        await dbhandler.store_in_db(data["msg"], room_name.replace(" ", "_"), NAMES[websocket.id], websocket.id, receivers)

def register_user(websocket, data):
    if "user_id" in data and "name" in data:
        websocket.id = data["user_id"]
        CONNECTIONS[websocket.id] = websocket
        NAMES[websocket.id] = data["name"]
        print("CONNECTIONS: ", CONNECTIONS)

async def main():
    # Set the stop condition when receiving SIGTERM.
    loop = asyncio.get_running_loop()
    stop = loop.create_future()
    loop.add_signal_handler(signal.SIGINT, stop.set_result, None)
    # Serve clients on websocket server
    async with websockets.serve(process_message, "0.0.0.0", 8765) as server:
        await stop

asyncio.run(main())

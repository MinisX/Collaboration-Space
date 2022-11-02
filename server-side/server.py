#!/usr/bin/env python

import asyncio
import datetime
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
    data = jsonhelper.is_json(msg)
    print("data for register_id: ", data)
    # Register user id when they first log in
    if data is not None:
        register_user(websocket, data)
    async for msg in websocket:
        print("Message is: ", msg)
        data = jsonhelper.is_json(msg)
        print("Message after JSON parse: ", data)
        # Manage rooms of users
        if data is not None:
            roomsets.manage_user_in_rooms(websocket, data)
        # Else send to users in the same room
        else:
            await send_store_msg(websocket, msg)

# Send message to other clients
async def send_store_msg(websocket, msg):
    new_msg = "{\"name\": \"" + NAMES[websocket.id] + "\", \"msg\": \"" + msg + "\"}"
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
    dbhandler.store_in_db(msg, room_name, websocket.id, receivers)

def register_user(websocket, data):
    if "register_id" in data:
        websocket.id = data["user_id"]
        CONNECTIONS[websocket.id] = websocket
        NAMES[websocket.id] = data["name"]
        print("CONNECTIONS: ", CONNECTIONS)

# Pull message from Db in case if client reconnects
async def pull_message():
    collection = dbhandler.open_collection()
    result = collection.find({
        "date" : { "$gte" : datetime.datetime.utcnow() - datetime.timedelta(days=1)}
    })
    return result

""" # handle the client
async def handler(websocket):
    consumer_task = asyncio.create_task(process_message(websocket))
    producer_task = asyncio.create_task(send_message_to_room(websocket))
    done, pending = await asyncio.wait(
        [consumer_task, producer_task],
        return_when=asyncio.FIRST_COMPLETED,
    )
    for task in pending:
        task.cancel() """

async def main():
    # Set the stop condition when receiving SIGTERM.
    loop = asyncio.get_running_loop()
    stop = loop.create_future()
    loop.add_signal_handler(signal.SIGINT, stop.set_result, None)
    # Serve clients on websocket server
    async with websockets.serve(process_message, "0.0.0.0", 8765) as server:
        await stop

if __name__ == "__main__":
    asyncio.run(main())

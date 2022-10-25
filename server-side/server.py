#!/usr/bin/env python

import asyncio
import signal
import websockets
import pymongo
import dbhandler
import roomhandler
import jsonhelper

participant_data = None
user_dict = dict()

# process messages
async def process_message(websocket):
    async for message in websocket: 
        await send_message_to_room(websocket, message)

# Send message to other clients
async def send_message_to_room(ws, msg):
    # See if user has changed rooms
    print(msg)      # Debugger statement
    print(type(msg))        # Debugger statement
    if (jsonhelper.is_json(msg)):
        print("it's json!")     # Debugger statement
        global participant_data
        participant_data = jsonhelper.parse_json(msg)
        store_user_room(participant_data)
        roomhandler.add_user_to_room(ws, participant_data)
        # Broadcast a message to users in the same room
        print(roomhandler.room1, roomhandler.room2, roomhandler.room3)      # Debugger statement
    elif ws in roomhandler.room1:
        for user in roomhandler.room1:
            # if (ws != user):
                print("inside room_1")      # Debugger statement
                await user.send(msg)
                await ws.send("room1 USEEEEER!")        # Debugger statement
                dbhandler.update_db(msg, participant_data)
    elif ws in roomhandler.room2:
        for user in roomhandler.room2:
            # if (ws != user):
                print("inside room_2")      # Debugger statement
                await user.send(msg)
                await ws.send("room2 USEEEEER!")        # Debugger statement
                dbhandler.update_db(msg, participant_data)
    elif ws in roomhandler.room3:
        for user in roomhandler.room3:
            # if (ws != user):
                print("inside room_3")      # Debugger statement
                await user.send(msg)
                await ws.send("room3 USEEEEER!")        # Debugger statement
                dbhandler.update_db(msg, participant_data)
    else:
        await ws.send("Error: user doesn't belong to a room!")      # Debugger statement

def store_user_room(data):
    global user_dict
    user_dict = {data["user_id"], data["room"]}
    print(user_dict)        # Debugger statement

""" # Pull message from Db in case if client reconnects
async def pull_message():
    collection = open_collection()
    result = collection.find({
        "date" : { "$lte" : datetime.datetime.utcnow() - datetime.datetime.day}
    })

# handle the client
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

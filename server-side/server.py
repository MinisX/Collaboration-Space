#!/usr/bin/env python

import asyncio
import signal
import websockets
import pymongo
import datetime
import mongodbconnector

connected_clients = set()  

# Open suitable DB collection
def open_collection():
    return mongodbconnector.client.chat_godot.user1_2

# process messages
async def process_message(websocket):
    # Register client.
    connected_clients.add(websocket)
    try:
        async for message in websocket: 
            await update_db(websocket, message)
    finally:
        # Unregister client.
        connected_clients.remove(websocket)

# Send message to other clients
async def send_message(ws, msg):
    """ message = await pull_message()
    await websocket.send(message) """
    # Broadcast a message to all connected clients.
    for client in connected_clients:
        if (ws != client):
            await client.send(msg)

# Store message in DB
async def update_db(ws, msg):
    try:
        collection = open_collection()
        await send_message(ws, msg)
        message = {
            "sender": "user1", 
            "receiver": "user2", 
            "message": msg, 
            "date": datetime.datetime.utcnow()
            }
        message_id = collection.insert_one(message)
        print("Successfully inserted message into DB.")
    except Exception as e:
        print("failed to insert into DB: ", e)

# Pull message from Db in case if client reconnects
async def pull_message():
    collection = open_collection()
    result = collection.find({
        "date" : { "$lte" : datetime.datetime.utcnow() - datetime.datetime.day}
    })

# handle the client
async def handler(websocket):
    consumer_task = asyncio.create_task(process_message(websocket))
    producer_task = asyncio.create_task(send_message(websocket))
    done, pending = await asyncio.wait(
        [consumer_task, producer_task],
        return_when=asyncio.FIRST_COMPLETED,
    )
    for task in pending:
        task.cancel()

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

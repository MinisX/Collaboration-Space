#!/usr/bin/env python

import asyncio
import websockets
import pymongo
import datetime
import mongodbconnector

connected_clients = set()

def open_collection():
    return mongodbconnector.client.chat_godot.user1_2

async def consume_message(websocket):
    # Register client.
    connected_clients.add(websocket)
    try:
        async for message in websocket: 
            await update_db(message, websocket)
    finally:
        # Unregister client.
        connected_clients.remove(websocket)
    # message = await websocket.recv()
    # await websocket.wait_closed()

async def produce_message(websocket):
    message = await pull_message()
    await websocket.send(message)

async def update_db(msg, ws):
    try:
        # Broadcast a message to all connected clients.
        for client in connected_clients:
            if (ws != client):
                await client.send(msg)
        collection = open_collection()
        message = {"sender": "user1", "receiver": "user2", "message": msg, "date": datetime.datetime.utcnow()}
        message_id = collection.insert_one(message)
        # message_id = collection.insert_one(msg).inserted_id
        # print(message_id)
        print("Successfully inserted message into DB.")
    	# await websocket.send("Successfully inserted message into DB.")
    except Exception as e:
        print("failed to insert into DB", e)
        # await websocket.send("Failed to insert messages into DB.")

async def pull_message():
    collection = open_collection()
    result = collection.find({
        "date" : { "$lte" : datetime.datetime.utcnow() - datetime.datetime.day}
    })

async def handler(websocket):
    consumer_task = asyncio.create_task(consume_message(websocket))
    producer_task = asyncio.create_task(produce_message(websocket))
    done, pending = await asyncio.wait(
        [consumer_task, producer_task],
        return_when=asyncio.FIRST_COMPLETED,
    )
    for task in pending:
        task.cancel()

async def main():
    async with websockets.serve(consume_message, "0.0.0.0", 8765):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
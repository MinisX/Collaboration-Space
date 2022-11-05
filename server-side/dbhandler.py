import motor.motor_asyncio
import traceback
import datetime

# Get MongoDB Client and open DB connection
def get_database():
    # Connect to localhost on port 27017
    client = motor.motor_asyncio.AsyncIOMotorClient('localhost', 27017)
    return client

# Open suitable DB collection
def open_collection(collection):
    return get_database().chat_godot[collection]

# Store message in DB
async def store_in_db(msg, room, name, id, receivers):
    try:
        collection = open_collection(room)
        message = {
            "sender_id": id,
            "sender_name": name,
            "recipients_id": receivers, 
            "message": msg, 
            "date": datetime.datetime.utcnow()
            }
        await collection.insert_one(message)
    except Exception as e:
        traceback.print_exc()

# Pull message from Db in case if client re-enters room
async def send_retrieve_message(websocket, collection, user_id):
    result = list()
    collection = open_collection(collection)
    async for document in collection.find({"$or": [{"sender_id": user_id,}, {"recipients_id" : {"$in": [user_id]}}],
                            "date" : { "$gte" : datetime.datetime.utcnow() - datetime.timedelta(days=1)}},
                            {"_id": 0, "sender_name": 1, "message": 1}):
        result.append(document)
    await websocket.send("{\"type\": \"retrieve_message\", \"result\": \"" + str(result) + "\"}")

client = get_database()
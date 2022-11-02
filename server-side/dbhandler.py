import pymongo
import traceback
import datetime
import jsonhelper

# Get MongoDB Client and open DB connection
def get_database():
    # Connect on port 27017 and set a 5-second connection timeout
    client = pymongo.MongoClient('localhost', 27017, serverSelectionTimeoutMS=5000)
    return client

# Open suitable DB collection
def open_collection(collection):
    return get_database().chat_godot[collection]

# Store message in DB
def store_in_db(msg, room, id, receivers):
    try:
        collection = open_collection(room)
        message = {
            "sender_id": id,
            "receivers_id": receivers, 
            "message": msg, 
            "date": datetime.datetime.utcnow()
            }
        message_id = collection.insert_one(message).inserted_id
        print("Successfully inserted message into DB.", message_id)     # Debugger statement
    except Exception as e:
        traceback.print_exc()

client = get_database()
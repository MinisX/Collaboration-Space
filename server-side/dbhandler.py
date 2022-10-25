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
    return client.chat_godot[collection]

# Store message in DB
def update_db(msg, participant_data):
    try:
        if participant_data is not None:
            collection_name = participant_data["room"]
            if (not jsonhelper.is_json(msg)):
                collection = open_collection(collection_name)
                message = {
                    "sender_id": participant_data["user_id"], 
                    "message": msg, 
                    "date": datetime.datetime.utcnow()
                    }
                message_id = collection.insert_one(message).inserted_id
                print("Successfully inserted message into DB.")     # Debugger statement
    except Exception as e:
        traceback.print_exc()

client = get_database()
import pymongo
import datetime

def get_database():
    # Connect on port 27017 and set a 5-second connection timeout
    client = pymongo.MongoClient('localhost', 27017, serverSelectionTimeoutMS=5000)
    return client
    # try:
        # chatdb = client.chat_godot
        # user1_2 = chatdb.user1_2
        # message = {"sender": "user1", "receiver": "user2", "message": "hello", "date": datetime.datetime.utcnow()}
        # message_id = user1_2.insert_one(message).inserted_id
        # print(message_id)
    # except Exception:
        # print("Unable to connect to the server.")

client = get_database()

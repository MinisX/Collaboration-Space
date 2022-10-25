import pymongo
import datetime

def get_database():
    # Connect on port 27017 and set a 5-second connection timeout
    client = pymongo.MongoClient('localhost', 27017, serverSelectionTimeoutMS=5000)
    return client

client = get_database()


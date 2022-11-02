import json

# Chek if the string is a correct JSON format
def parse_json(msg):
    try:
        data = json.loads(msg)
    except Exception as e:
        return None
    return data
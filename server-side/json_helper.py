import json

# Parse JSON from string
def parse_json(participant_data):
    participant_data = json.loads(participant_data)
    return participant_data

# Chek if the string is a correct JSON format
def is_json(json_string):
    try:
        json.loads(json_string)
    except ValueError as e:
        return False
    return True
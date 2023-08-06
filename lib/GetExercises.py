import requests
import json

url = "https://exercisedb.p.rapidapi.com/exercises"

headers = {
	"X-RapidAPI-Key": "24d7fdb755mshe9ad7b273211de1p160e9bjsn32244367e3e3",
	"X-RapidAPI-Host": "exercisedb.p.rapidapi.com"
}

response = requests.get(url, headers=headers)

map=response.json()
names_list=[]
print(map)
with open('data.json', 'w') as json_file:
    json.dump(map, json_file)
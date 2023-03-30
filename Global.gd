# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

var player = "Quingee"

# true when a screen pops up and player should focus on the dialogue box
var freezeQuingee = false

# global player stats
var currentHunger = 20
var maxHunger = 20
var exploreCount = 0
var timesFailed = 0

enum CheckpointType {
	THROAT,
	RIVER,
	STEPS,
	PEAK
}
var currentCheckpoint = CheckpointType.THROAT
var highestFloor = 1

# global world stats
var currentDay = 1
var currentWeather = "Sunny"
var futureWeather = "Sunny"

# global town stats
var npc_dialogue: JSON = load("res://dialogue/NPCs.json")
var npcData = []

func generateWeather():
	var chance = randi_range(1,100)
	if chance <= 69:
		futureWeather = "Sunny"
	elif chance <= 79:
		futureWeather = "Rainy"
	elif chance <= 89:
		futureWeather = "Cloudy"
	elif chance <= 99:
		futureWeather = "Windy"
	else:
		futureWeather = "Stormy"

func newDay():
	currentDay += 1
	currentWeather = futureWeather
	generateWeather()
	generateNPCs()

func generateNPCs():
	# logic for the conditions
	var charas = []
	var locations = ["Lake Galinn"]
	npcData = {}
	for n in 3:
		print(charas, locations)
		var npc = _weighted_rand(charas, locations)
		npcData[n] = npc
		npcData[n].visited = false
		charas.push_back(npc.name)
		locations.push_back(npc.location)
	print(npcData)
		
func _weighted_rand(charas, locations):
	var sortedDialogue = npc_dialogue.data.values().filter(
		# add condition logic
		func filter(i):
			if i.name in charas:
				return false
			elif i.location in locations:
				return false
			elif i.condition == "After at least 3 explorations":
				return exploreCount >= 3
			elif i.condition == "Failed once":
				return timesFailed >= 1
			elif i.condition == "High inventory count":
				return Inventory.get_inv_count() >= Inventory.max * .80
			elif i.condition == "River unlocked":
				return currentCheckpoint >= CheckpointType.RIVER
			elif i.condition == "Steps unlocked":
				return currentCheckpoint >= CheckpointType.STEPS
			elif i.condition in ["Sunny", "Cloudy", "Windy", "Rainy", "Stormy"]:
				return i.condition == currentWeather
			else:
				return true
	)
	sortedDialogue.sort_custom(
		func sort_by_popularity(a, b):
			return a.popularity < b.popularity
	)
	var randInd = (round(sortedDialogue.size() / (randf_range(0, 1) * sortedDialogue.size() + 1))) - 1;
	sortedDialogue[randInd].popularity += 1;
	return sortedDialogue[randInd];

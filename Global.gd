# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

enum CheckpointType {
	THROAT = 0,
	RIVER = 10,
	STEPS = 25,
	PEAK = 45,
	TOP = 75
}

# true when a screen pops up and player should focus on the dialogue box
var freezeQuingee = false

# global player stats
var player = "Quingee"
var currentHunger = 0
var maxHunger = 50
var exploreCount = 0
var timesFailed = 0
var currentCheckpoint = CheckpointType.THROAT
var currentFloor = 30
var highestFloor = 0
var ozChance = 0.0
var wanderChance = 0.0

# global world stats
var currentDay = 1
var currentWeather = "Sunny"
var futureWeather = "Sunny"
var weatherList = ["Sunny", "Cloudy", "Windy", "Rainy", "Stormy"]

# global town stats
var npc_dialogue: JSON = load("res://dialogue/NPCs.json")
var npcData = []
var FP = {
	"bullfrog": 0,
	"noah": 0,
	"oleander": 0,
	"oz": 0,
	"piper": -1,
	"reinhardt": 0,
	"wander": 0,
	"zane": 0,
	"panqing": 0
}
var dialogue_popularity = {
	"bullfrog": {},
	"noah": {},
	"oleander": {},
	"oz": {},
	"piper": {},
	"reinhardt": {},
	"wander": {},
	"zane": {},
	"panqing": {}
}
var daily_bakeroast_items = []
var last_town_menu_button

func _ready():
	generateNPCs()

func save():
	var save_dict = {
		"player" : player,
		"maxHunger" : maxHunger,
		"exploreCount" : exploreCount,
		"timesFailed" : timesFailed,
		"currentCheckpoint" : currentCheckpoint,
		"highestFloor" : highestFloor,
		"currentDay" : currentDay,
		"currentWeather" : currentWeather,
		"futureWeather" : futureWeather
	}
	return save_dict

func load_data(node_data):
	assert(node_data, "We ball if the save file data is corrupt.")
	player = node_data.player
	maxHunger = node_data.maxHunger
	exploreCount = node_data.exploreCount
	timesFailed = node_data.timesFailed
	currentCheckpoint = node_data.currentCheckpoint
	highestFloor = node_data.highestFloor
	currentDay = node_data.currentDay
	currentWeather = node_data.currentWeather
	futureWeather = node_data.futureWeather

func newDay():
	currentDay += 1
	currentWeather = futureWeather
	generateWeather()
	generateNPCs()
	daily_bakeroast_items = []

func generateWeather():
	var chance = randi_range(1,100)
	if chance <= 65:
		futureWeather = "Sunny"
	elif chance <= 75:
		futureWeather = "Rainy"
	elif chance <= 85:
		futureWeather = "Cloudy"
	elif chance <= 95:
		futureWeather = "Windy"
	else:
		futureWeather = "Stormy"

func generateNPCs():
	# logic for the conditions
	var charas = []
	var locations = ["Lake Galinn"]
	npcData = {}
	for n in 3:
		var npc = _weighted_rand(charas, locations)
		npcData[n] = npc
		npcData[n].visited = false
		charas.push_back(npc.name)
		locations.push_back(npc.location)
		
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
			elif i.condition in weatherList:
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

func advanceFloor():
	currentFloor += 1
	if currentFloor >= highestFloor:
		highestFloor = currentFloor
		currentCheckpoint = CheckpointType[get_checkpoint_name().to_upper()]
	if currentFloor >= CheckpointType.TOP:
		# TODO: go to peak cutscene
		SceneManager.change_scene("Map")
	elif currentFloor == CheckpointType.PEAK:
		# get custom map
		SceneManager.change_scene("Mountain")
	elif currentFloor == CheckpointType.STEPS:
		# get custom map
		SceneManager.change_scene("Mountain")
	elif currentFloor == CheckpointType.RIVER:
		# get custom map
		SceneManager.change_scene("Mountain")
	elif currentFloor == 15 and FP.piper < 0:
		# get piper scene
		SceneManager.change_scene("Mountain")
	elif currentFloor >= CheckpointType.PEAK and (ozChance >= randf_range(0, 1) or \
		currentFloor <= CheckpointType.PEAK - 1):
		ozChance = -1.0
		# get oz map
		SceneManager.change_scene("Mountain")
	elif wanderChance >= randf_range(0, 1):
		wanderChance = 0.0
		# get wander map
		SceneManager.change_scene("Map")
	else:
		if currentFloor >= CheckpointType.PEAK:
			ozChance = pow(currentFloor - CheckpointType.PEAK / CheckpointType.TOP - CheckpointType.PEAK, 5.0)
			print(ozChance, "ozchance")
		wanderChance = pow((currentFloor % 10) / 10.0, 3.0)
		if wanderChance <= 0.0:
			wanderChance = 1.0
		print(wanderChance, "wanderChance")
		SceneManager.change_scene("Mountain")

func get_checkpoint_name(floor=currentFloor):
	if floor <= CheckpointType.RIVER:
		return "Throat"
	elif floor <= CheckpointType.STEPS:
		return "River"
	elif floor <= CheckpointType.PEAK:
		return "Steps"
	else:
		return "Peak"

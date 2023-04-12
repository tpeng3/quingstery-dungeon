# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

@export var items_json: JSON

@export var gald = 999
var storage = {
	"Trash": {
		"name": "Trash",
		"count": 5
	}
}
var inventory = {
	"Acorn": {
		"name": "Acorn",
		"count": 5
	},
	"Stick of Hay": {
		"name": "Stick of Hay",
		"count": 1
	},
	"Glowbug": {
		"name": "Glowbug",
		"count": 3
	},
	"Silk": {
		"name": "Silk",
		"count": 5
	},
	"Trash": {
		"name": "Trash",
		"count": 5
	}
}
var max = 20
var equipped = ["Stick of Hay"]
const STORAGE_MAX = 99

func get_items_json():
	return items_json.data

func add_gald(amount):
	gald += amount
	
func remove_gald(amount):
	gald -= max(amount, 0)

func add_item(key, count=1, addToStorage=false):
	var item = find_item(key)
	assert(item, "Key Error: This item does not exist: " + key)
	var box = storage if addToStorage else inventory
	
	# town items that can't be added to inventory go straight to storage
	var store = count
	var remainder = 0
	if !addToStorage and Global.currentFloor <= 0:
		store = min(count, max - get_inv_count())
		remainder = count - store
		if key in storage:
			storage[key].count += remainder
		else:
			storage[key] = {
				"name": item.name,
				"count": remainder
			}
	if key in box:
		box[key].count += store
	else:
		box[key] = {
			"name": item.name,
			"count": store
		}
	return remainder > 0
		
func remove_item(key, count=1, takeFromStorage=false):
	var item = find_item(key)
	assert(item, "Key Error: This item does not exist: " + key)
	var box = storage if takeFromStorage else inventory
	if key in box:
		box[key].count -= count
		if box[key].count <= 0:
			box.erase(key)
		
# UI calls this to get a sorted array of player's inventory
func print_items(printStorage=false):
	var inv = []
	var box = storage if printStorage else inventory
	for key in box:
		var item = find_item(key)
		if item.type == "Upgrade":
			continue
		inv.push_back({
			"name": box[key].name,
			"count": box[key].count
		})
#		var remainder = box[key].count
#		for n in ceil(remainder / item.maxcount):
#			if remainder >= item.maxcount:
#				inv.push_back({
#					"name": box[key].name,
#					"count": item.maxcount
#				})
#				remainder -= item.maxcount
#			else:
#				inv.push_back({
#					"name": box[key].name,
#					"count": remainder
#				})
	return inv

# UI call this to view how much items have taken up inventory space
func get_inv_count(getStorage=false):
	var count = 0
	var box = storage if getStorage else inventory
	for key in box:
		var item = find_item(key)
		if item.type == "Upgrade":
			continue
		count += box[key].count
	return count

func find_item(key):
	for i in items_json.data:
		if i.name == key:
			return i
	return null

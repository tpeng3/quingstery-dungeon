# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

@export var items_json: JSON

@export var gald = 0
var inventory = {}
var max = 20

func get_items_json():
	return items_json.data

func add_gald(amount):
	gald += amount
	
func remove_gald(amount):
	gald -= max(amount, 0)

# TODO: add an error when inventory is maxed, and prompt user to toss items
func add_item(key, count=1):
	var item = _find_item(key)
	assert(item, "Key Error: This item does not exist: " + key)
	if key in inventory:
		inventory[key].count += count
	else:
		inventory[key] = {
			"name": item.name,
			"path": item.path,
			"count": count
		}
		
func remove_item(key, count=1):
	var item = _find_item(key)
	assert(item, "Key Error: This item does not exist: " + key)
	if key in inventory:
		inventory[key].count -= count
		if inventory[key].count <= 0:
			inventory.erase(key)
		
# UI calls this to get a sorted array of player's inventory
func print_items():
	var inv = []
	for key in inventory:
		var item = _find_item(key)
		var remainder = inventory[key].count
		for n in ceil(item.count / item.maxcount):
			if remainder >= item.maxcount:
				inv.push({
					"name": inventory[key].name,
					"path": inventory[key].path,
					"count": item.maxcount
				})
				remainder -= item.maxcount
			else:
				inv.push({
					"name": inventory[key].name,
					"path": inventory[key].path,
					"count": remainder
				})
	return inv

# UI call this to view how much items have taken up inventory space
func get_inv_count():
	var count = 0
	for key in inventory:
		var item = _find_item(key)
		count += ceil(inventory[key].count / item.maxcount)
	return count

func _find_item(key):
	var i = items_json.data.find(func(i): i.name == key)
	return items_json.data[i]

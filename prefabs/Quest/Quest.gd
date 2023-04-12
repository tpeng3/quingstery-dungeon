# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

@export var quests_json: JSON

var quests = {
}
const QUESTS_MAX = 24

func get_quests_json():
	return quests_json.data

#func accept_quest()
#func reject_quest()
#func complete_quest()
	
# UI calls this to get a sorted array of player's inventory
#func print_items(printStorage=false):
#	var inv = []
#	var box = storage if printStorage else inventory
#	for key in box:
#		var item = find_item(key)
#		if item.type == "Upgrade":
#			continue
#		inv.push_back({
#			"name": box[key].name,
#			"count": box[key].count
#		})
#	return inv

func get_completed_count():
	var count = 0
	for key in quests:
		if quests[key].status == "Completed":
			count += 1
	return count

# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

var player = "Quingee"

# true when a screen pops up and player should focus on the dialogue box
var freezeQuingee = false

# global player stats
var currentHunger = 20
var maxHunger = 20

# global world stats
var currentDay = 1
var currentWeather = "Sunny"
var futureWeather = "Sunny"

func generateWeather():
	var chance = randi_range(1,100)
	
	futureWeather = "Sunny" if chance >= 1 and chance <= 69 else "Rainy" if chance >= 70 and chance <= 79 else "Cloudy" if chance >= 80 and chance <= 89 else "Windy" if chance >= 90 and chance <= 99 else "Stormy"

func newDay():
	currentDay += 1
	currentWeather = futureWeather
	Global.generateWeather()

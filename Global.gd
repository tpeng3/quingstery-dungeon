# Global file to handle scene swiching and global functions
# This is a singleton so script is preloaded before game starts
extends Node

var player = "Quingee"

# true when a screen pops up and player should focus on the dialogue box
var freezeQuingee = false

# global player stats
var currentHunger = 20
var maxHunger = 20

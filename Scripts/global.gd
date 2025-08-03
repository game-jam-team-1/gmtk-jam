extends Node


var player: Player
var main_menu: MainMenu

var current_level_index: int
var level_unlock_state: Array[bool] = [
	true,
	false,
	false,
	false,
]

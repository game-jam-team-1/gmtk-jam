class_name World
extends Node2D

@export var rounds: int

@export var packages_each_round: Array[int]

var current_round: int
var packages_this_round: int

var time_left: float = 24 * 60

signal new_year(round: int)
signal game_finished()

func _ready() -> void:
	new_year.emit(0)

func package_collected() -> void:
	Global.Player.collected_packages -= 1
	packages_this_round += 1
	if packages_this_round >= packages_each_round[current_round]:
		packages_this_round = 0
		time_left = 24 * 60
		current_round += 1
		new_year.emit(current_round)
		if current_round >= rounds:
			game_finished.emit()

func _process(delta: float) -> void:
	time_left -= 15 * delta
	
	if time_left <= 0:
		print("Timeout! You lose")

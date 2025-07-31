class_name World
extends Node2D

@export var rounds: int

@export var packages_each_round: Array[int]

var current_round: int
var packages_this_round: int

signal new_round(round: int)
signal game_finished()

func _ready() -> void:
	new_round.emit(0)

func package_collected() -> void:
	packages_this_round += 1
	if packages_this_round >= packages_each_round[current_round]:
		current_round += 1
		new_round.emit(current_round)
		if current_round >= rounds:
			game_finished.emit()

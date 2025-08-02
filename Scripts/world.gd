class_name World
extends Node2D

@export var level_number: int
@export var rounds: int

@export var packages_each_round: Array[int]
@export var time_each_round: Array[float]

@onready var time_left: float = time_each_round[0]

var current_round: int
var packages_this_round: int

signal new_year(round: int)
signal game_finished()

func _ready() -> void:
	new_year.emit(0)

func package_collected() -> void:
	Global.player.collected_packages -= 1
	packages_this_round += 1
	if packages_this_round >= packages_each_round[current_round]:
		packages_this_round = 0
		time_left = time_each_round[current_round]
		current_round += 1
		new_year.emit(current_round)
		if current_round >= rounds:
			complete_level()
			game_finished.emit()

func _process(delta: float) -> void:
	time_left -= 10 * delta
	
	if time_left <= 0:
		print("Timeout! You lose")

func complete_level() -> void:
	queue_free()
	get_parent().get_node("MainMenu").level_unlock_state.set(level_number + 1, true)
	get_parent().get_node("MainMenu").visible = true
	get_parent().get_node("Camera2D").enabled = true
	get_parent().get_node("Background").visible = true

class_name MainMenu
extends Node2D

@onready var level = load("uid://debprahfmmn1a")

func _on_play_button_up() -> void:
	get_tree().change_scene_to_packed(level)

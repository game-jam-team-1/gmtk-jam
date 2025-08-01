class_name MainMenu
extends Node2D

@onready var level = preload("res://Scenes/world.tscn")

func _on_button_button_up() -> void:
	get_tree().change_scene_to_packed(level)


func _on_texture_button_button_up() -> void:
	get_tree().change_scene_to_packed(level)

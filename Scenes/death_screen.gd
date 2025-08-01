extends Control


@onready var level = load("uid://debprahfmmn1a")
@onready var menu = load("uid://djxxe8osn1t8a")


func _on_restart_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(level)

func _on_menu_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(menu)

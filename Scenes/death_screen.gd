extends Control


@onready var levels: Array[String] = [
	"res://Scenes/Levels/tutorial.tscn",
	"res://Scenes/Levels/level1.tscn",
	"res://Scenes/Levels/level2.tscn",
	"res://Scenes/Levels/level3.tscn"
]

@onready var menu: String= "res://Scenes/main_menu.tscn"


func _on_restart_button_up() -> void:
	self.visible = false
	get_tree().paused = false
	print(Global.current_level_index)
	get_tree().change_scene_to_file(levels[Global.current_level_index])

func _on_menu_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(menu)

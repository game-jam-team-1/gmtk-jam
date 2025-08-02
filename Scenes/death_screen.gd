extends Control


@onready var menu = load("uid://djxxe8osn1t8a")


func _on_restart_button_up() -> void:
	self.visible = false
	get_tree().paused = false
	Global.current_level_root.queue_free()
	Global.main_menu.play_level(Global.current_level)

func _on_menu_button_up() -> void:
	get_tree().paused = false
	Global.current_level_root.queue_free()
	Global.main_menu.activate_main_menu()

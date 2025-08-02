class_name MainMenu
extends CanvasLayer

var is_ready: bool = false

var level_unlock_state: Array[bool] = [
	true,
	false,
	false,
	false,
]

@onready var buttons: Array[TextureButton] = [
	$"Container/HBoxContainer/1",
	$"Container/HBoxContainer/2",
	$"Container/HBoxContainer/3",
	$"Container/HBoxContainer/4",
]

@onready var levels = [
	preload("res://Scenes/tutorial.tscn"),
	preload("res://Scenes/world.tscn"),
	preload("res://Scenes/world2.tscn"),
]

func _process(delta: float) -> void:
	for i in range(buttons.size()):
		if level_unlock_state[i]:
			buttons[i].disabled = false
		else:
			buttons[i].disabled = true

func start() -> void:
	visible = true
	$"Container".modulate.a = 0.0
	get_tree().create_tween().tween_property($"Container", "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	is_ready = true

func deactivate_main_menu() -> void:
	visible = false
	get_parent().get_node("Camera2D").enabled = false
	get_parent().get_node("Background").visible = false

# Hey it's a game jam ok ;(
func on_1_pressed() -> void:
	if is_ready && levels[0]:
		deactivate_main_menu()
		get_parent().add_child(levels[0].instantiate())

func on_2_pressed() -> void:
	if is_ready && levels[1]:
		deactivate_main_menu()
		get_parent().add_child(levels[1].instantiate())

func on_3_pressed() -> void:
	if is_ready && levels[2]:
		deactivate_main_menu()
		get_parent().add_child(levels[2].instantiate())

func on_4_pressed() -> void:
	if is_ready && levels[3]:
		deactivate_main_menu()
		get_parent().add_child(levels[3].instantiate())

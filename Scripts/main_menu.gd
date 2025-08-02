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
	load("uid://pqhd4r2ifve")
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


# Hey it's a game jam ok ;(
func on_1_pressed() -> void:
	if is_ready && levels[0]:
		get_tree().change_scene_to_packed(levels[0])

func on_2_pressed() -> void:
	if is_ready && levels[1]:
		get_tree().change_scene_to_packed(levels[1])

func on_3_pressed() -> void:
	if is_ready && levels[2]:
		get_tree().change_scene_to_packed(levels[2])

func on_4_pressed() -> void:
	if is_ready && levels[3]:
		get_tree().change_scene_to_packed(levels[3])

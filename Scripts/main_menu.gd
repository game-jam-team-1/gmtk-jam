class_name MainMenu
extends CanvasLayer

var is_ready: bool = false

@onready var buttons: Array[TextureButton] = [
	$"Container/HBoxContainer/1",
	$"Container/HBoxContainer/2",
	$"Container/HBoxContainer/3",
	$"Container/HBoxContainer/4",
]

@onready var levels: Array[Resource] = [
	preload("res://Scenes/Levels/tutorial.tscn"),
	preload("res://Scenes/Levels/level1.tscn"),
	preload("res://Scenes/Levels/level2.tscn"),
	preload("res://Scenes/Levels/level3.tscn")
]

func _process(delta: float) -> void:
	for i in range(buttons.size()):
		if Global.level_unlock_state[i]:
			buttons[i].disabled = false
		else:
			buttons[i].disabled = true

func start() -> void:
	Global.main_menu = self
	
	visible = true
	$"Container".modulate.a = 0.0
	get_tree().create_tween().tween_property($"Container", "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	is_ready = true

# Hey it's a game jam ok ;(
func on_1_pressed() -> void:
	play_level(0)

func on_2_pressed() -> void:
	play_level(1)

func on_3_pressed() -> void:
	play_level(2)

func on_4_pressed() -> void:
	play_level(3)


func play_level(a: int):
	if is_ready && levels[a]:
		$"Click".play()
		Global.current_level_index = a
		get_tree().change_scene_to_packed(levels[a])

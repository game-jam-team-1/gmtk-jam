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
	Global.main_menu = self
	
	visible = true
	$"Container".modulate.a = 0.0
	get_tree().create_tween().tween_property($"Container", "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5).timeout
	is_ready = true

func deactivate_main_menu() -> void:
	visible = false
	get_parent().get_node("Camera2D").enabled = false
	get_parent().get_node("Background").visible = false

func activate_main_menu() -> void:
	visible = true
	get_parent().get_node("Camera2D").enabled = true
	get_parent().get_node("Background").visible = true

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
		
		deactivate_main_menu()
		Global.current_level = a
		var level: Node = levels[a].instantiate()
		get_parent().add_child(level)
		Global.current_level_root = level

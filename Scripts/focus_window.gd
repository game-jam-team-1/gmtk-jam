class_name FocusWindow
extends CanvasLayer

var is_ready: bool = false

@onready var main_menu: MainMenu = $"../MainMenu"

func _ready() -> void:
	start()

func start() -> void:
	$"Label".modulate.a = 0.0
	get_tree().create_tween().tween_property($"Label", "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	is_ready = true

func on_mouse_down() -> void:
	if is_ready:
		get_tree().create_tween().tween_property($"ColorRect", "modulate:a", 0.0, 1.0)
		get_tree().create_tween().tween_property($"Label", "modulate:a", 0.0, 1.0)
		
		await get_tree().create_timer(1.0).timeout
		visible = false
		
		main_menu.start()

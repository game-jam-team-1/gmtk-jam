class_name FocusWindow
extends CanvasLayer

@onready var main_menu: MainMenu = $"../MainMenu"

var clicked: bool = false

func _ready() -> void:
	start()

func start() -> void:
	$"Label".modulate.a = 0.0
	get_tree().create_tween().tween_property($"Label", "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(1.0).timeout

func on_mouse_down() -> void:
	if !clicked:
		clicked = true
		
		$"Click".play()
		
		get_tree().create_tween().tween_property($"ColorRect", "modulate:a", 0.0, 1.0)
		get_tree().create_tween().tween_property($"Label", "modulate:a", 0.0, 1.0)
		
		await get_tree().create_timer(1.0).timeout
		visible = false
		
		main_menu.start()

class_name ScreenColor
extends ColorRect

signal screen_flash_done

const flash_duration: float = 1.0

var flashing = false

func _ready() -> void:
	visible = true
	color = Color.BLACK
	tween_alpha_to(0.0, 1.0)

func tween_alpha_to(alpha: float, time: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color:a", alpha, time)

func flash_cycle():
	tween_alpha_to(0.25, flash_duration/2)
	await get_tree().create_timer(flash_duration/2).timeout
	tween_alpha_to(0, flash_duration/2)
	await get_tree().create_timer(flash_duration/2).timeout
	if flashing:
		flash_cycle()

func start_flashing() -> void:
	color = Color(Color.RED, 0.0)
	flash_cycle()
	flashing = true

func stop_flashing() -> void:
	flashing = false

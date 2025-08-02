class_name ScreenColor
extends ColorRect


const low_fuel_warning: String = "WARNING: Fuel low! Return to spawn planet to refuel!"
const self_destruct_warning: String = "WARNING: Out of fuel, self destruct sequence initiated! Return to a planet immediately!!!"

const flash_duration: float = 1.0

var flashing = false

@onready var fuel_warning = $"../FuelWarning"

func _ready() -> void:
	visible = true
	color = Color.BLACK
	tween_alpha_to(0.0, 1.0)

func tween_alpha_to(alpha: float, time: float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color:a", alpha, time)

func flash_cycle():
	fuel_warning.visible = true
	tween_alpha_to(0.25, flash_duration/2)
	await get_tree().create_timer(flash_duration/2).timeout
	fuel_warning.visible = false
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

func self_destructing() -> void:
	fuel_warning.text = self_destruct_warning

func stop_self_destructing() -> void:
	fuel_warning.text = low_fuel_warning

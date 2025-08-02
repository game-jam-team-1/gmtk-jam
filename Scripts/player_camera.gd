class_name PlayerCamera
extends Camera2D

var shake_timer: float = 2.0
var shake_force: float = 0.0

func shake(duration: float, force: float) -> void:
	shake_timer = duration
	shake_force = force

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		position.x += randi_range(-shake_force, shake_force)
		position.y += randi_range(-shake_force, shake_force)

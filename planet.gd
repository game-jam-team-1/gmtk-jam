class_name Planet
extends AnimatableBody2D

@export var orbit_enabled: bool = false
@export var orbit_planet: Planet
@export var orbit_speed: float = 5.0


func _physics_process(delta: float) -> void:
	if !orbit_enabled:
		return
	
	var angle: float = global_position.angle_to_point(orbit_planet.global_position)
	
	constant_linear_velocity = Vector2.from_angle(angle + PI/2) * orbit_speed
	
	global_position += constant_linear_velocity * delta * 60

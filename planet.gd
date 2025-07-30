class_name Planet
extends AnimatableBody2D

@export var orbit_enabled: bool = false
@export var orbit_planet: Planet
@export var orbit_speed: float = 0.01

var distance: float = 0.0
var current_angle: float = 0.0

func _ready() -> void:
	if !orbit_enabled:
		return
	
	distance = global_position.distance_to(orbit_planet.global_position)
	current_angle = orbit_planet.global_position.angle_to_point(global_position)

func _physics_process(delta: float) -> void:
	if !orbit_enabled:
		return
	
	current_angle += orbit_speed * delta * 60
	
	constant_linear_velocity = (orbit_planet.global_position + Vector2.from_angle(current_angle) * distance) - global_position
	global_position = orbit_planet.global_position + Vector2.from_angle(current_angle) * distance

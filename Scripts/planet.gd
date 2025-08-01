class_name Planet
extends AnimatableBody2D

@export var refills_fuel: bool = false
@export var orbit_planet: Planet
@export var orbit_speed: float = 0.01

# This is for player / objects on top of planet to inherit
var previous_position: Vector2
var velocity: Vector2 = Vector2.ZERO

# Orbit stuff
var distance: float = 0.0
var current_angle: float = 0.0

@onready var radius: float = $CollisionShape2D.shape.radius * scale.x


func _ready() -> void:
	if !orbit_planet:
		return

	distance = global_position.distance_to(orbit_planet.global_position)
	current_angle = orbit_planet.global_position.angle_to_point(global_position)
	previous_position = global_position


func _physics_process(delta: float) -> void:
	if !orbit_planet:
		return
	
	current_angle += orbit_speed * delta * 60
	
	global_position = orbit_planet.global_position + Vector2.from_angle(current_angle) * distance
	velocity = (global_position - previous_position) / delta
	
	previous_position = global_position


func get_radius() -> float:
	return radius

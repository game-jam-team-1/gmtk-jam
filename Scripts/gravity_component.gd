class_name GravityComponent
extends Node2D

@onready var body: RigidBody2D = get_parent()

@export var gravity_detection_area: Area2D

@export var raycasts_container: Node

var gravity_vel: Vector2

var closest_gravity_area: GravityArea

func physics() -> void:
	var areas = gravity_detection_area.get_overlapping_areas()
	
	if areas.size() == 0:
		closest_gravity_area = null
	
	var current_gravity_dist: float = INF
	if closest_gravity_area != null:
		current_gravity_dist = global_position.distance_to(closest_gravity_area.global_position)
	
	for area in areas:
		if area is not GravityArea:
			continue
		
		area = area as GravityArea
		
		if area.global_position.distance_to(global_position) < current_gravity_dist:
			closest_gravity_area = area
	
	if !closest_gravity_area:
		return
	
	var planet_center: Vector2 = closest_gravity_area.global_position
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	
	get_parent().rotation = upwards_angle + PI/2
	
	if _is_on_ground():
		gravity_vel = Vector2.ZERO
	else:
		gravity_vel += Vector2.from_angle(upwards_angle + PI) * closest_gravity_area.accel

func _is_on_ground() -> bool:
	for raycast: RayCast2D in raycasts_container.get_children():
		if raycast.is_colliding():
			return true
	return false

func integrate() -> void:
	var planet_velocity: Vector2 = Vector2.ZERO
	if closest_gravity_area:
		planet_velocity = (closest_gravity_area.get_parent() as Planet).constant_linear_velocity * 60
	body.linear_velocity = gravity_vel + planet_velocity
	

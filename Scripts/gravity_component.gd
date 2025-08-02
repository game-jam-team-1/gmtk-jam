class_name GravityComponent
extends Area2D

@export var parent: RigidBody2D

var closest_gravity_area: GravityArea = null
var gravitational_force: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var areas = get_overlapping_areas()  # Returns empty on first frame
	var nearest_area: GravityArea = null
	var shortest_distance: float = INF
	
	# Find the closest valid GravityArea
	for area in areas:
		if area is GravityArea:
			var distance = get_distance_to_gravity_area(area)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_area = area
	
	closest_gravity_area = nearest_area


func update_gravity_force(delta: float) -> void:
	if not closest_gravity_area:
		gravitational_force = Vector2.ZERO
		return

	if not parent.has_method("is_on_ground"):
		printerr("Parent doesn't have method 'is_on_ground', returning")
		return
	
	var planet_center: Vector2 = closest_gravity_area.global_position
	var gravity_dir: float = planet_center.angle_to_point(global_position) + PI
	
	if parent.is_on_ground():
		gravitational_force = Vector2.from_angle(gravity_dir) * 10 * delta * 60
	else:
		
		gravitational_force += Vector2.from_angle(gravity_dir) * closest_gravity_area.accel * delta * 60


func get_distance_to_gravity_area(gravity_area: GravityArea) -> float:
	if gravity_area == null:
		return 0.0
	
	# Account for surface distance
	return global_position.distance_to(gravity_area.global_position) - gravity_area.planet.radius


func get_gravitational_force() -> Vector2:
	return gravitational_force

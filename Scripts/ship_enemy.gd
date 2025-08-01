class_name ShipEnemy
extends CharacterBody2D

@export var max_speed: float

@export var path_line: Line2D

var target_index: int = 1

func _process(delta: float) -> void:
	path_line.visible = false

func _physics_process(delta: float) -> void:
	var target: Vector2 = path_line.to_global(path_line.points[target_index])
	velocity = lerp(velocity, global_position.direction_to(target) * max_speed, 0.02)
	position += velocity * delta
	rotation += angle_difference(rotation, velocity.angle() + PI) * 0.05
	
	if global_position.distance_to(target) < 30:
		target_index += 1
		if target_index == path_line.points.size():
			target_index = 0

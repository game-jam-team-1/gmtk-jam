class_name TurretBullet
extends Area2D

var velocity: Vector2

## Speed in pixels per second.
func setup(pos: Vector2, direction: Vector2, speed: float) -> void:
	self.top_level = true
	global_position = pos
	velocity = direction * speed

func _process(delta: float) -> void:
	position += velocity * delta
	global_rotation = velocity.angle()

func kills_on_collision() -> bool:
	return true

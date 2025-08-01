extends Camera2D

@export var speed: float = 100

var direction: float = 0.0
var target_direction: float = 0.0

var randomization_time: float = 0.0

func _ready() -> void:
	randomize_direction()

func _physics_process(delta: float) -> void:
	direction = lerp_angle(direction, target_direction, 0.001)
	
	randomization_time -= delta
	if randomization_time <= 0:
		randomize_direction()
	
	print(angle_difference(direction, target_direction))
	position += Vector2.from_angle(direction) * speed * delta

func randomize_direction() -> void:
	randomization_time += randf_range(5, 15)
	target_direction = randf_range(0,2*PI)

class_name Player
extends RigidBody2D

const JUMP_VEL: float = 1000
const ACCEL: float = 300

@onready var just_jumped_timer: SceneTreeTimer = get_tree().create_timer(0)

@onready var gravity_detection_area: Area2D = $"Area2D"
@onready var ground_raycast: RayCast2D = $"RayCast2D"

var jump_velocity: Vector2
var strafe_velocity: Vector2

func _physics_process(delta: float) -> void:
	var areas = gravity_detection_area.get_overlapping_areas()
	var up_direction: Vector2
	
	print(just_jumped_timer.time_left)
	
	for area in areas:
		if area is GravityArea:
			area = area as GravityArea
			rotation = (global_position - area.global_position).angle() + PI / 2.0
			jump_velocity += (area.global_position - global_position).normalized() * area.accel
			up_direction = (global_position - area.global_position).normalized()
	
	if _is_on_ground() && just_jumped_timer.time_left == 0:
		jump_velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("jump") && _is_on_ground():
		just_jumped_timer = get_tree().create_timer(0.1)
		jump_velocity = up_direction * JUMP_VEL
	
	var direction: float = 0.0
	
	if Input.is_action_pressed("left"):
		direction += 1
	if Input.is_action_pressed("right"):
		direction -= 1
	
	if direction != 0:
		strafe_velocity = up_direction.rotated(-90 * direction) * ACCEL
	else:
		strafe_velocity = Vector2(0,0)
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	print(jump_velocity, " ", strafe_velocity)
	linear_velocity = jump_velocity + strafe_velocity

func _is_on_ground() -> bool:
	return ground_raycast.is_colliding()

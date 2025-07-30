class_name Player
extends RigidBody2D

const JUMP_VEL: float = 600
const LONG_JUMP_VEL: float = 1000
const BOOSTER_VEL: float = 700
const ACCEL: float = 300

@onready var just_jumped_timer: SceneTreeTimer = get_tree().create_timer(0)

@onready var gravity_detection_area: Area2D = $"Area2D"
@onready var ground_raycast: RayCast2D = $"RayCast2D"

var jump_velocity: Vector2
var strafe_velocity: Vector2
var closest_area: GravityArea

func _physics_process(delta: float) -> void:
	var areas = gravity_detection_area.get_overlapping_areas()
	var up_direction: Vector2
	
	var closest_distance: float = INF
	
	var has_gravity_area = false
	for area in areas:
		if area is GravityArea:
			has_gravity_area = true
			area = area as GravityArea
			rotation = (global_position - area.global_position).angle() + PI / 2.0
			jump_velocity += (area.global_position - global_position).normalized() * area.accel
			up_direction = (global_position - area.global_position).normalized()
			
			if area.position.distance_to(position) < closest_distance:
				closest_area = area
	
	if _is_on_ground() && just_jumped_timer.time_left == 0:
		jump_velocity = Vector2.ZERO
	
	if Input.is_action_just_pressed("long_jump") && _is_on_ground():
		just_jumped_timer = get_tree().create_timer(0.1)
		jump_velocity = up_direction * LONG_JUMP_VEL
	elif Input.is_action_just_pressed("jump") && _is_on_ground():
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
	
	if !has_gravity_area:
		rotation -= 3 * direction * delta
		if Input.is_action_pressed("jump"):
			jump_velocity = Vector2.from_angle(rotation-PI/2) * BOOSTER_VEL

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var planet_velocity: Vector2 = Vector2.ZERO
	if closest_area:
		planet_velocity = (closest_area.get_parent() as Planet).constant_linear_velocity * 60
	linear_velocity = jump_velocity + strafe_velocity + planet_velocity

func _is_on_ground() -> bool:
	return ground_raycast.is_colliding()

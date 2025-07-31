class_name PlayerMovement
extends Node2D

signal thruster_boosted()

const JUMP_FORCE: float = 1500
const HIGH_JUMP_FORCE: float = 2500
const JUST_JUMP_GRACE_PERIOD: float = 0.15

const WALK_SPEED: float = 600

const THRUSTER_FORCE: float = 40
const THRUSTER_MAX_VELOCITY: float = 900
const THRUSTER_MAX_FUEL: float = 100

const REFUEL_RATE: float = 10
const USAGE_RATE: float = 10

var target_gravity_velocity: Vector2 = Vector2.ZERO
var gravity_velocity: Vector2 = Vector2.ZERO

var strafe_velocity: Vector2 = Vector2.ZERO
var jump_velocity: Vector2 = Vector2.ZERO
var thruster_velocity: Vector2 = Vector2.ZERO

var thruster_fuel: float = 100.0

var closest_gravity_area: GravityArea

var just_jumped: bool = false
var just_jumped_time: float = 0.0

var is_grounded_movement: bool = false
var grounded_movement_dir: int = 0

var is_thruster_movement: bool = false
var is_thruster_on: bool = false

@onready var gravity_detection_area: Area2D = $"GravityDetectionArea"

@onready var ground_raycasts: Array[RayCast2D] = [
	$"FloorCasts/RayCast1",
	$"FloorCasts/RayCast2",
	$"FloorCasts/RayCast3",
]

@onready var fuel_bar: ProgressBar = $"../../CanvasLayer/FuelBar"

@onready var player: Player = get_parent()


func _ready() -> void:
	fuel_bar.max_value = THRUSTER_MAX_FUEL

func _physics_process(delta: float) -> void:
	fuel_bar.value = thruster_fuel
	
	# Count down the jump buffer
	if just_jumped_time > 0:
		just_jumped_time -= delta
	else:
		just_jumped = false
	
	_process_gravity_area()


func _process_grounded_movement(delta: float) -> void:
	is_grounded_movement = true
	is_thruster_movement = false
	
	var planet_center: Vector2 = closest_gravity_area.global_position
	
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	
	player.rotation = upwards_angle + PI/2
	
	if is_on_ground():
		if closest_gravity_area.get_parent().refills_fuel && thruster_fuel < THRUSTER_MAX_FUEL:
			thruster_fuel += REFUEL_RATE * delta
		
		target_gravity_velocity = Vector2.ZERO
		gravity_velocity = target_gravity_velocity
		
		jump_velocity = Vector2.ZERO
		
		if Input.is_action_just_pressed("high_jump"):
			just_jumped = true
			just_jumped_time = JUST_JUMP_GRACE_PERIOD
			
			jump_velocity = Vector2.from_angle(upwards_angle) * HIGH_JUMP_FORCE
			
		elif Input.is_action_just_pressed("jump"):
			just_jumped = true
			just_jumped_time = JUST_JUMP_GRACE_PERIOD
			
			jump_velocity = Vector2.from_angle(upwards_angle) * JUMP_FORCE
	else:
		target_gravity_velocity += Vector2.from_angle(upwards_angle + PI) * closest_gravity_area.accel
		gravity_velocity = target_gravity_velocity
	
	strafe_velocity = Vector2.ZERO
	
	grounded_movement_dir = 0
	
	if Input.is_action_pressed("left"):
		grounded_movement_dir += 1
		strafe_velocity -= Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED
	if Input.is_action_pressed("right"):
		grounded_movement_dir -= 1
		strafe_velocity += Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED
	
	# Reduce thruster movement
	thruster_velocity = thruster_velocity.lerp(Vector2.ZERO, 0.5)


func _process_thruster_movement(delta: float) -> void:
	is_thruster_movement = true
	is_grounded_movement = false
	
	var angle_to_mouse: float = global_position.angle_to_point(get_global_mouse_position())
	player.rotation = angle_to_mouse + PI/2
	
	is_thruster_on = false
	
	if thruster_fuel <= 0:
		return
	
	if Input.is_action_just_pressed("jump"):
		thruster_boosted.emit()
		thruster_velocity += Vector2.from_angle(angle_to_mouse) * THRUSTER_FORCE * 5
		thruster_fuel -= USAGE_RATE * delta * 5
		
	elif Input.is_action_pressed("jump"):
		is_thruster_on = true
		thruster_velocity += Vector2.from_angle(angle_to_mouse) * THRUSTER_FORCE
		thruster_fuel -= USAGE_RATE * delta
	
	if thruster_velocity.length() > THRUSTER_MAX_VELOCITY:
		thruster_velocity = thruster_velocity.normalized() * THRUSTER_MAX_VELOCITY
	
	# Reduce grounded movement
	strafe_velocity = strafe_velocity.lerp(Vector2.ZERO, 0.5)
	jump_velocity = jump_velocity.lerp(Vector2.ZERO, 0.5)
	
	target_gravity_velocity = target_gravity_velocity.lerp(Vector2.ZERO, 0.5)
	gravity_velocity = gravity_velocity.lerp(Vector2.ZERO, 0.5)


func _process_gravity_area() -> void:
	var areas = gravity_detection_area.get_overlapping_areas()
	
	if areas.size() == 0:
		closest_gravity_area = null
	
	var current_gravity_dist: float = 9999999
	if closest_gravity_area != null:
		current_gravity_dist = global_position.distance_to(closest_gravity_area.global_position)
	
	var detected_area: bool = false
	for area in areas:
		if area is not GravityArea:
			continue
		
		detected_area = true
		
		area = area as GravityArea
		
		if area.global_position.distance_to(global_position) < current_gravity_dist:
			closest_gravity_area = area
	
	if !detected_area:
		closest_gravity_area = null


func is_on_ground() -> bool:
	if just_jumped:
		return false
	
	for ray in ground_raycasts:
		if ray.is_colliding():
			return true
	
	return false

func get_velocity() -> Vector2:
	return gravity_velocity + strafe_velocity + jump_velocity + thruster_velocity

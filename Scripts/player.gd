class_name Player
extends RigidBody2D

const JUMP_FORCE: float = 1000
const HIGH_JUMP_FORCE: float = 2000
const JUST_JUMP_GRACE_PERIOD: float = 0.15

const WALK_SPEED: float = 300
const THRUSTER_FORCE: float = 40
const THRUSTER_MAX_VELOCITY: float = 500
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

var collected_packages: int = 0
var deposited_packages: int = 0

@onready var gravity_detection_area: Area2D = $"GravityDetectionArea"
@onready var large_detection_area: Area2D = $"LargeDetectionArea"

@onready var ground_raycast: RayCast2D = $"RayCast2D"
@onready var fuel_bar: ProgressBar = $"../CanvasLayer/FuelBar"


func _ready() -> void:
	Global.Player = self
	
	fuel_bar.max_value = THRUSTER_MAX_FUEL


func _physics_process(delta: float) -> void:
	_process_gravity_area()
	_process_packages()
	
	fuel_bar.value = thruster_fuel
	
	# Count down the jump buffer
	if just_jumped_time > 0:
		just_jumped_time -= delta
	else:
		just_jumped = false
	
	if closest_gravity_area:
		_process_grounded_movement(delta)
		thruster_velocity = Vector2.ZERO
	else:
		_process_thruster_movement(delta)
		strafe_velocity = Vector2.ZERO
		jump_velocity = Vector2.ZERO
		target_gravity_velocity = Vector2.ZERO
		gravity_velocity = Vector2.ZERO
	
	for body in get_colliding_bodies():
		if body.has_method("kills_on_collision"):
			die()


func _process_grounded_movement(delta: float) -> void:
	var planet_center: Vector2 = closest_gravity_area.global_position
	
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	
	rotation = upwards_angle + PI/2
	
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
	
	if Input.is_action_pressed("left"):
		strafe_velocity -= Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED
	if Input.is_action_pressed("right"):
		strafe_velocity += Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED


func _process_thruster_movement(delta: float) -> void:
	var angle_to_mouse: float = global_position.angle_to_point(get_global_mouse_position())
	rotation = angle_to_mouse + PI/2
	
	if Input.is_action_pressed("jump") && thruster_fuel > 0:
		thruster_velocity += Vector2.from_angle(angle_to_mouse) * THRUSTER_FORCE
		thruster_fuel -= USAGE_RATE * delta
		
	
	if thruster_velocity.length() > THRUSTER_MAX_VELOCITY:
		thruster_velocity = thruster_velocity.normalized() * THRUSTER_MAX_VELOCITY


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


func _process_packages() -> void:
	var closest_package: Package
	var package_depot: PackageDepot
	for area in large_detection_area.get_overlapping_areas():
		if area.name == "PackageArea" && !closest_package:
			closest_package = area.get_parent()
		if area.name == "PackageDepotArea":
			package_depot = area.get_parent()
	
	if Input.is_action_just_pressed("interact") && package_depot:
		collected_packages = 0
		
	$OnePackage.visible = false
	$TwoPackages.visible = false
	$ThreePackages.visible = false
	
	if collected_packages == 1:
		$OnePackage.visible = true
	if collected_packages == 2:
		$TwoPackages.visible = true
	if collected_packages == 3:
		$ThreePackages.visible = true
	
	if !closest_package:
		return
	
	if Input.is_action_just_pressed("interact") && collected_packages < 3:
		collected_packages += 1
		closest_package.queue_free()
		print("Collected Package -- New count: " + str(collected_packages))


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var planet_velocity: Vector2 = Vector2.ZERO
	
	if closest_gravity_area:
		planet_velocity = (closest_gravity_area.get_parent() as Planet).velocity
	
	linear_velocity = gravity_velocity + strafe_velocity + jump_velocity + thruster_velocity + planet_velocity


func is_on_ground() -> bool:
	if just_jumped:
		return false
	
	return ground_raycast.is_colliding()

func die():
	print("you died")

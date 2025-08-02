class_name PlayerMovement
extends Node2D

signal thruster_boosted()

const JUMP_FORCE: float = 1500
const HIGH_JUMP_FORCE: float = 2500
const JUST_JUMP_GRACE_PERIOD: float = 0.15

const WALK_SPEED: float = 600

const THRUSTER_FORCE: float = 40
const THRUSTER_MAX_VELOCITY: float = 1200
const THRUSTER_MAX_FUEL: float = 100

const REFUEL_RATE: float = 10
const USAGE_RATE: float = 10

var strafe_velocity: Vector2 = Vector2.ZERO
var jump_velocity: Vector2 = Vector2.ZERO
var thruster_velocity: Vector2 = Vector2.ZERO

var thruster_fuel: float = 100.0
var screen_flashing: bool = false
var refueling: bool = false
var self_destruct_sequence_initiatied: bool = false

var just_jumped: bool = false
var just_jumped_time: float = 0.0

var is_grounded_movement: bool = false
var grounded_movement_dir: int = 0

var is_thruster_movement: bool = false
var just_started_thruster_movement: bool = false
var is_thruster_on: bool = false

@onready var gravity_component: GravityComponent = $"GravityComponent"

@onready var ground_raycasts: Array[RayCast2D] = [
	$"FloorCasts/RayCast1",
	$"FloorCasts/RayCast2",
	$"FloorCasts/RayCast3",
]

@onready var fuel_bar: TextureProgressBar = $"../UI/FuelBar"
@onready var self_destruct_timer: Timer = $"SelfDestructTimer"
@onready var screen_color: ScreenColor = $"../UI/ScreenColor"
@onready var player: Player = get_parent()

func _ready() -> void:
	fuel_bar.max_value = THRUSTER_MAX_FUEL

func _process(delta: float) -> void:
	fuel_bar.value = thruster_fuel
	
	if thruster_fuel <= 20:
		if !screen_flashing && !refueling:
			screen_color.start_flashing()
			screen_flashing = true
			
			print("1")
			player.player_audio.is_low_fuel = true
			
		if thruster_fuel <= 0 && !is_on_ground() && !self_destruct_sequence_initiatied:
			screen_color.self_destructing()
			self_destruct_sequence_initiatied = true
			self_destruct_timer.start()
			print(self_destruct_timer.time_left)
			
		elif self_destruct_sequence_initiatied && (is_on_ground() || thruster_fuel > 0):
			screen_color.stop_self_destructing()
			self_destruct_sequence_initiatied = false
			self_destruct_timer.stop()
			
	elif screen_flashing:
		screen_color.stop_flashing()
		screen_flashing = false
		
		# This never runs, idk why xavier idk how you do it
		# so i had to make my own thing for the audio below ts
		player.player_audio.is_low_fuel = false
	
	if refueling || thruster_fuel > 20:
		player.player_audio.is_low_fuel = false
	
	# Count down the jump buffer
	if just_jumped_time > 0:
		just_jumped_time -= delta
	else:
		just_jumped = false


func _process_grounded_movement(delta: float) -> void:
	var planet: Planet = gravity_component.closest_gravity_area.planet
	var planet_center: Vector2 = gravity_component.closest_gravity_area.global_position
	
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	
	player.rotation = upwards_angle + PI/2
	
	if is_on_ground():
		if planet.refills_fuel && thruster_fuel < THRUSTER_MAX_FUEL:
			thruster_fuel += REFUEL_RATE * delta
			refueling = true
			if screen_flashing:
				screen_flashing = false
				screen_color.stop_flashing()
		
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
		refueling = false
	
	strafe_velocity = Vector2.ZERO
	
	grounded_movement_dir = 0
	
	if Input.is_action_pressed("left"):
		grounded_movement_dir += 1
		strafe_velocity -= Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED
	if Input.is_action_pressed("right"):
		grounded_movement_dir -= 1
		strafe_velocity += Vector2.from_angle(upwards_angle + PI/2) * WALK_SPEED
	
	# Reduce thruster movement
	thruster_velocity = Vector2.ZERO
	
	just_started_thruster_movement = true


func _process_thruster_movement(delta: float) -> void:
	grounded_movement_dir = 0
	
	var angle_to_mouse: float = global_position.angle_to_point(get_global_mouse_position())
	player.rotation = angle_to_mouse + PI/2
	
	is_thruster_on = false
	
	if thruster_fuel <= 0:
		return
	
	if Input.is_action_just_pressed("jump"):
		thruster_boosted.emit()
		thruster_velocity += Vector2.from_angle(angle_to_mouse) * THRUSTER_FORCE * 10
		thruster_fuel -= USAGE_RATE * delta * 5
		
	elif Input.is_action_pressed("jump"):
		is_thruster_on = true
		thruster_velocity += Vector2.from_angle(angle_to_mouse) * THRUSTER_FORCE
		thruster_fuel -= USAGE_RATE * delta
		
	else:
		thruster_velocity *= 0.99
	
	if thruster_velocity.length() > THRUSTER_MAX_VELOCITY:
		thruster_velocity = thruster_velocity.normalized() * THRUSTER_MAX_VELOCITY
	
	if just_started_thruster_movement:
		jump_velocity += gravity_component.get_gravitational_force()
		
		gravity_component.gravitational_force = Vector2.ZERO
	
	# Reduce grounded movement
	strafe_velocity = Vector2.ZERO
	jump_velocity = jump_velocity.lerp(Vector2.ZERO, 0.02)
	
	#just_started_thruster_movement = false


func is_on_ground() -> bool:
	if just_jumped:
		return false
	
	for ray in ground_raycasts:
		if ray.is_colliding():
			return true
	
	return false


func get_velocity() -> Vector2:
	var vel: Vector2 = strafe_velocity + jump_velocity + thruster_velocity
	
	if is_grounded_movement:
		vel += gravity_component.get_gravitational_force()
	
	if is_thruster_movement:
		vel += gravity_component.get_gravitational_force() * 0.05
	
	return vel

func set_grounded_movement() -> void:
	is_grounded_movement = true
	is_thruster_movement = false

func set_thruster_movement() -> void:
	is_thruster_movement = true
	is_grounded_movement = false

func self_destruct_timer_timeout() -> void:
	print("goo boom")
	Global.player.die()

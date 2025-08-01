class_name CrawlerEnemy
extends RigidBody2D

const CRAWL_VEL = 300

@export var clockwise: bool = true

var direction: int
var crawl_velocity: Vector2
var gravity_velocity: Vector2 = Vector2.ZERO
var closest_gravity_area = null

@onready var gravity_detection_area = $"GravityDetection"
@onready var ground_raycast = $"GroundRaycast"
@onready var animations: AnimatedSprite2D = $"AnimatedSprite2D"

func _ready() -> void:
	if clockwise:
		direction = 1
	else:
		direction = -1
		#scale flipping doesnt really work rn
		scale.x = -scale.x
	
	animations.play("walk")

func _physics_process(delta: float) -> void:
	var up_direction: Vector2 = Vector2.ZERO
	
	_process_gravity_area()
	
	if closest_gravity_area != null:
		rotation = (global_position - closest_gravity_area.global_position).angle() + PI / 2
		up_direction = (global_position - closest_gravity_area.global_position).normalized()
		gravity_velocity += (closest_gravity_area.global_position - global_position).normalized() * closest_gravity_area.accel
	
	if is_on_ground():
		gravity_velocity = Vector2.ZERO
		crawl_velocity = up_direction.rotated(90 * direction) * CRAWL_VEL
	else:
		crawl_velocity = Vector2.ZERO

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var planet_velocity: Vector2 = Vector2.ZERO
	if closest_gravity_area:
		planet_velocity = (closest_gravity_area.get_parent() as Planet).velocity
	linear_velocity = crawl_velocity + planet_velocity + gravity_velocity


func _process_gravity_area() -> void:
	var areas = gravity_detection_area.get_overlapping_areas()
	
	if areas.size() == 0:
		closest_gravity_area = null
	
	var current_gravity_dist: float = 9999999
	if closest_gravity_area != null:
		current_gravity_dist = global_position.distance_to(closest_gravity_area.global_position)
	
	for area in areas:
		if area is not GravityArea:
			return
		
		area = area as GravityArea
		
		if area.global_position.distance_to(global_position) < current_gravity_dist:
			closest_gravity_area = area

func is_on_ground() -> bool:
	return ground_raycast.is_colliding()

func flip():
	clockwise = !clockwise
	direction = -direction
	scale.x = -scale.x

func kills_on_collision() -> bool:
	return true

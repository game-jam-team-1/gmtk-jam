extends RigidBody2D


enum STATE {
	IDLE,
	TARGETING,
	AGGRO,
}

const PLAYER_DETECTION_RANGE: float = 1000.0
const AGGRO_THRESHOLD: float = 2.0
const MAX_AGGRO: float = 3.0
const MAX_BARREL_ROTATION: float = PI/2

var planet_velocity = Vector2.ZERO
var gravity_velocity = Vector2.ZERO
var state: STATE = STATE.IDLE
var aggro_value: float = 0.0
var rotation_direction = 1
var center_rotation = global_rotation

@onready var ground_raycast: RayCast2D = $"GroundRaycast"
@onready var player_raycast: RayCast2D = $"Pivot/PlayerRaycast"
@onready var pivot: Node2D = $"Pivot"

@onready var shaft_animation: AnimatedSprite2D = $"Pivot/AnimatedSprite2D"

@onready var bullet = preload("uid://de75elo7ykf0g")

@onready var bullet_shoot_timer: SceneTreeTimer = get_tree().create_timer(1.0 / bullet_frequency)

@export var bullet_speed: float = 1000.0 # pixels per second
@export var bullet_frequency: float = 2.0 # bullet per second


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	_proccess_movement()
	player_detection(delta)
	
	
	if state == STATE.IDLE:
		idle(delta)
	else:
		target()
		if state == STATE.AGGRO:
			aggro()

func _proccess_movement():
	rotation = (position).angle() + PI/2.0
	planet_velocity = get_parent().velocity
	
	if !is_on_ground():
		gravity_velocity += (get_parent().global_position - global_position).normalized() * get_parent().get_node("Area2D").accel
	else:
		gravity_velocity = Vector2.ZERO


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	linear_velocity = gravity_velocity + planet_velocity


func player_detection(delta: float):
	if player_raycast.get_collider() == Global.Player:
		if state == STATE.IDLE:
			state = STATE.TARGETING
		elif state == STATE.TARGETING:
			aggro_value += delta
			if aggro_value >= AGGRO_THRESHOLD:
				state = STATE.AGGRO
		else:
			if aggro_value < MAX_AGGRO:
				aggro_value += delta
	else:
		if state == STATE.TARGETING:
			aggro_value -= delta
			if aggro_value <= 0:
				state = STATE.IDLE
				pivot.rotation = 0
		elif state == STATE.AGGRO:
			aggro_value -= delta
			if aggro_value < AGGRO_THRESHOLD:
				state = STATE.TARGETING


func idle(delta):
	pivot.rotation += rotation_direction * delta
	if abs(pivot.rotation) >= MAX_BARREL_ROTATION:
		rotation_direction = -rotation_direction


func target():
	pivot.rotation = clamp(normalize_angle((pivot.global_position - Global.Player.global_position).angle() - PI/2 - global_rotation), -MAX_BARREL_ROTATION, MAX_BARREL_ROTATION)


func aggro():
	if bullet_shoot_timer.time_left == 0:
		bullet_shoot_timer = get_tree().create_timer(1 / bullet_frequency)
		
		var new_bullet: TurretBullet = bullet.instantiate()
		add_child(new_bullet)
		
		shaft_animation.play("shoot")
		
		
		new_bullet.setup(pivot.global_position, Vector2.from_angle(pivot.rotation - PI / 2.0), bullet_speed)


func is_on_ground() -> bool:
	return ground_raycast.is_colliding()


func normalize_angle(a: float) -> float:
	a = fmod(fmod(a,2*PI)+2*PI,2*PI)
	if a > PI:
		a-=2*PI
	return a

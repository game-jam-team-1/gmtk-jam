class_name Player
extends RigidBody2D

enum DamagedState {
	NORMAL,
	INVINCIBLE,
	DAMAGED,
}

var invincible_timer: SceneTreeTimer
var damaged_timer: SceneTreeTimer

var invincible_time: float = 1.0
var damaged_time: float = 5.0

var collected_packages: int = 0

var duplicated_balls: Array

var damaged_state: DamagedState 

var sending_package_depot: PackageDepot
var sending_packages_to_depot: bool = false

@onready var gravity_component: GravityComponent = $"PlayerMovement/GravityComponent"
@onready var large_detection_area: Area2D = $"LargeDetectionArea"
@onready var fuel_bar: TextureProgressBar = $"UI/FuelBar"
@onready var arrow: Node2D = $"Arrow"

@onready var player_movement: PlayerMovement = $"PlayerMovement"
@onready var player_animation: PlayerAnimation = $"PlayerAnimation"

@onready var world: World = get_parent()


func _ready() -> void:
	player_movement.is_grounded_movement = true
	Global.player = self

func _process(delta: float) -> void:
	$UI/TimeBar.value = world.time_left

func _physics_process(delta: float) -> void:
	_process_packages()
	
	_update_movement_mode()
	
	gravity_component.update_gravity_force(delta)
	
	if player_movement.is_grounded_movement:
		player_movement._process_grounded_movement(delta)
	
	if player_movement.is_thruster_movement:
		player_movement._process_thruster_movement(delta)
	
	_process_death()

func _update_movement_mode() -> void:
	var grav_area: GravityArea = gravity_component.closest_gravity_area
	
	if grav_area != null:
		var distance = gravity_component.get_distance_to_gravity_area(grav_area)
		
		if player_movement.is_thruster_movement && distance < 100:
			player_movement.set_grounded_movement()
		
	else:
		player_movement.set_thruster_movement()

## BAd
func _process_death() -> void:
	if damaged_state == DamagedState.INVINCIBLE && invincible_timer.time_left == 0:
		$DamagedAnimations.play("damaged")
		damaged_state = DamagedState.DAMAGED
		damaged_timer = get_tree().create_timer(damaged_time)
	if damaged_state == DamagedState.DAMAGED && damaged_timer.time_left == 0:
		$DamagedAnimations.play("RESET")
		damaged_state = DamagedState.NORMAL
	
	var potential_killers: Array[Node2D]
	
	for body in get_colliding_bodies():
		potential_killers.append(body)
	for area in $PlayerMovement/GravityComponent.get_overlapping_areas():
		potential_killers.append(area)
	for node in potential_killers:
		if (node.has_method("kills_on_collision") && node.kills_on_collision()):
			if damaged_state == DamagedState.DAMAGED:
				die()
			if damaged_state == DamagedState.NORMAL:
				$DamagedAnimations.play("invincible")
				damaged_state = DamagedState.INVINCIBLE
				invincible_timer = get_tree().create_timer(invincible_time)

func _process_packages() -> void:
	var closest_package: Package
	for area in large_detection_area.get_overlapping_areas():
		if area.name == "PackageArea" && area.get_parent().spawned_in:
			closest_package = area.get_parent()
			break
	
	if !closest_package || closest_package.following_node:
		return
	
	if collected_packages < 100:
		collected_packages += 1
		closest_package.get_grabbed(self)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var planet_velocity: Vector2 = Vector2.ZERO
	
	if gravity_component.closest_gravity_area && is_on_ground():
		planet_velocity = gravity_component.closest_gravity_area.planet.velocity
	
	linear_velocity = player_movement.get_velocity() + planet_velocity

func is_on_ground() -> bool:
	return player_movement.is_on_ground()

func die():
	print("you died")
	$"UI/DeathScreen".visible = true
	get_tree().paused = true

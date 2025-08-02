class_name Player
extends RigidBody2D

var collected_packages: int = 0

var duplicated_balls: Array

var sending_package_depot: PackageDepot
var sending_packages_to_depot: bool = false

@onready var gravity_component: GravityComponent = $"PlayerMovement/GravityComponent"
@onready var large_detection_area: Area2D = $"LargeDetectionArea"
@onready var fuel_bar: ProgressBar = $"UI/FuelBar"
@onready var player_movement: PlayerMovement = $"PlayerMovement"
@onready var player_animation: PlayerAnimation = $"PlayerAnimation"
@onready var world: World = get_parent()


func _ready() -> void:
	player_movement.is_grounded_movement = true
	Global.Player = self

func _process(_delta: float) -> void:
	$UI/TimeLabel.text = "Year: " + str(world.current_round) + " | Hour: " + str(24 - int(world.time_left / 60.0)) + " | Presents: " + str(world.packages_this_round) + "/" + str(world.packages_each_round[world.current_round])

func _physics_process(delta: float) -> void:
	_process_packages()
	
	_update_movement_mode()
	
	if player_movement.is_grounded_movement:
		player_movement._process_grounded_movement(delta)
		gravity_component.update_gravity_force(delta)
	
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
	var potential_killers: Array[Node2D]
	
	for body in get_colliding_bodies():
		potential_killers.append(body)
	for area in $PlayerMovement/GravityComponent.get_overlapping_areas():
		potential_killers.append(area)
	for node in potential_killers:
		if (node.has_method("kills_on_collision") && node.kills_on_collision()):
			die()

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

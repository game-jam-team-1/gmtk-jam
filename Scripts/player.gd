class_name Player
extends RigidBody2D



var collected_packages: int = 0
var deposited_packages: int = 0


@onready var large_detection_area: Area2D = $"LargeDetectionArea"


@onready var player_movement: PlayerMovement = $"PlayerMovement"
@onready var player_animation: PlayerAnimation = $"PlayerAnimation"


func _physics_process(delta: float) -> void:
	_process_packages()
	
	
	if player_movement.closest_gravity_area:
		player_movement._process_grounded_movement(delta)
	else:
		player_movement._process_thruster_movement(delta)
	
	for body in get_colliding_bodies():
		if body.has_method("kills_on_collision"):
			queue_free()


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
	
	if player_movement.closest_gravity_area:
		planet_velocity = (player_movement.closest_gravity_area.get_parent() as Planet).velocity
	
	linear_velocity = player_movement.get_velocity() + planet_velocity




func die():
	queue_free()

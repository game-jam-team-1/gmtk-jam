class_name Santa
extends RigidBody2D

var met_santa: bool = false
var collected_package: bool = false
var final_dialog: bool = false

var player: Player

@onready var gravity_component: GravityComponent = $"GravityComponent"
@onready var detection_area: Area2D = $"PlayerDetectionArea"
@onready var world: World = get_parent()

func _finished() -> void:
	world.package_collected()

func _process(delta: float) -> void:
	if world.packages_this_round > 0 && !collected_package:
		world.package_collected()
		collected_package = true
		player = $"../Player"
		var dialog: DialogBox = player.get_node("UI/DialogBox")
		dialog.text_chain([
			"Good job collecting the package.",
			"Remember to only bring green packages to green planets, and blue packages to blue planets, and so on.",
			"Each present contains many other presents, and the santas of each planet will help deliver one to every child.",
			"Bring this blue present to the blue planet."
		])
	
	if world.current_round == 2 && !final_dialog:
		final_dialog = true
		player = $"../Player"
		var dialog: DialogBox = player.get_node("UI/DialogBox")
		dialog.text_chain([
			"You show great promise! It is time for you to head out into the galaxy.",
			"Fairwell!"
		])
		dialog.finished.connect(_finished)
	
	for area in $PlayerDetectionArea.get_overlapping_areas():
		if area.get_parent() is Player && !met_santa:
			player = area.get_parent()
			met_santa = true
			var dialog: DialogBox = player.get_node("UI/DialogBox")
			dialog.text_chain([
				"Ho ho ho! I am santa.\n\nPress space to continue the dialog.",
				"You can jump by pressing W, and high jump by pressing Shift+W.",
				"Your job is to collect presents and deliver them to children all around the galaxy.",
				"You can press E to collect packages.",
				"It is now time for you to leave the planet! Find a package and then bring it back to me.",
			])

func _physics_process(delta: float) -> void:
	gravity_component.update_gravity_force(delta)
	
	if !gravity_component.closest_gravity_area:
		return
	
	var planet_center: Vector2 = gravity_component.closest_gravity_area.global_position
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	rotation = upwards_angle + PI/2

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	linear_velocity = gravity_component.get_gravitational_force()

func is_on_ground() -> bool:
	print($RayCast2D.is_colliding())
	return $RayCast2D.is_colliding()

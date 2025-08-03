class_name Santa
extends RigidBody2D

@export var is_tutorial: bool = false

var met_santa: bool = false
var collected_package: bool = false
var final_dialogue: bool = false

var player: Player

@onready var gravity_component: GravityComponent = $"GravityComponent"
@onready var detection_area: Area2D = $"PlayerDetectionArea"
@onready var world: World = get_parent()

func _new_year(year: int) -> void:
	player = $"../Player"
	var dialogue: DialogueBox = player.get_node("UI/DialogueBox")
	dialogue.animate_writing_text("It is a new year! Year: " + str(year) + ". Packages: " + str(world.packages_each_round[world.current_round]))

func _ready() -> void:
	if !is_tutorial:
		world.new_year.connect(_new_year)
		return
	
	world.freeze_time = true

func _finished() -> void:
	world.package_collected()

func _process(delta: float) -> void:
	if !is_tutorial:
		return
	
	if world.packages_this_round > 0 && !collected_package:
		world.freeze_time = false
		world.package_collected()
		collected_package = true
		player = $"../Player"
		var dialogue: DialogueBox = player.get_node("UI/DialogueBox")
		$"Bells".play()
		dialogue.text_chain([
			"Good job, you collected the package.",
			"Remember to only bring packages to their corresponding planets. Green packages go to green planets, blue packages to blue planets, and so on.",
			"Each present contains many other presents, and the santas of each planet will help deliver one to every child.",
			"Bring this blue present to the blue planet."
		])
	
	if world.current_round == 2 && !final_dialogue:
		final_dialogue = true
		player = $"../Player"
		var dialogue: DialogueBox = player.get_node("UI/DialogueBox")
		$"Bells".play()
		dialogue.text_chain([
			"You show great promise! It is time for you to head out into the galaxy and deliver packages to children all across the cosmos!",
			"Fairwell!"
		])
		dialogue.finished.connect(_finished)
	
	for area in $PlayerDetectionArea.get_overlapping_areas():
		if area.get_parent() is Player && !met_santa:
			player = area.get_parent()
			met_santa = true
			var dialogue: DialogueBox = player.get_node("UI/DialogueBox")
			$"Bells".play()
			dialogue.text_chain([
				"Ho ho ho! I am santa.\n\nPress space to continue the dialogue.",
				"You can jump by pressing W, and high jump by pressing Shift+W.",
				"Your job is to collect presents and deliver them to children all around the galaxy, all within 24 hours.",
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
	if !gravity_component.closest_gravity_area:
		return
	
	linear_velocity = gravity_component.get_gravitational_force() + gravity_component.closest_gravity_area.planet.constant_linear_velocity

func is_on_ground() -> bool:
	return $RayCast2D.is_colliding()

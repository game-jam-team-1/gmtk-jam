class_name Package
extends RigidBody2D


@export var package_type: Planet.PlanetType

@export var spawn_round: int

@onready var gravity_component: GravityComponent = $"PackageArea"

@onready var red_package: Texture2D = preload("uid://cy1infg5mxchj")
@onready var blue_package: Texture2D = preload("uid://bqen3e7iajfp6")
@onready var green_package: Texture2D = preload("uid://vwl1gr3o022k")
@onready var purple_package: Texture2D = preload("uid://coaxubw1xq4xc")

var following_node: Node2D

var spawned_in: bool = false
var parent_offset_pos: Vector2

@onready var raycasts: Array[RayCast2D] = [
	$"Raycasts/RayCast1",
	$"Raycasts/RayCast2",
	$"Raycasts/RayCast3",
	$"Raycasts/RayCast4",
]

func _ready() -> void:
	$LargePackage.visible = false
	
	var sprite_using: Sprite2D
	
	var type: int = randi_range(1, 3)
	if type == 1:
		sprite_using = $SmallPackage
		$CollisionShapeSmall.disabled = false
	if type == 2:
		sprite_using = $MediumPackage
		$CollisionShapeMedium.disabled = false
	if type == 3:
		sprite_using = $LargePackage
		$CollisionShapeLarge.disabled = false
	
	sprite_using.visible = true
	if package_type == Planet.PlanetType.ORANGE:
		sprite_using.texture = red_package
	elif package_type == Planet.PlanetType.GREEN:
		sprite_using.texture = green_package
	elif package_type == Planet.PlanetType.BLUE:
		sprite_using.texture = blue_package
	
	parent_offset_pos = global_position - get_parent().global_position

func _physics_process(delta: float) -> void:
	if !spawned_in:
		if get_parent().get_parent().current_round >= spawn_round:
			spawned_in = true
		
		collision_layer = 0
		visible = false
		global_position = get_parent().global_position + parent_offset_pos
		return
	else:
		collision_layer = 1
		visible = true
	
	gravity_component.update_gravity_force(delta)
	
	if following_node && global_position.distance_to(following_node.global_position) > 200:
		global_position = lerp(global_position, following_node.global_position, 0.01)
	
	if !gravity_component.closest_gravity_area:
		return
	
	if gravity_component.closest_gravity_area.planet.planet_type == package_type:
		get_parent().get_parent().package_collected()
		queue_free()
	
	var planet_center: Vector2 = gravity_component.closest_gravity_area.global_position
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	rotation = upwards_angle + PI/2

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !visible:
		return
	
	var planet_velocity: Vector2
	if gravity_component.closest_gravity_area:
		planet_velocity = gravity_component.closest_gravity_area.planet.velocity
	
	if !following_node:
		linear_velocity = gravity_component.get_gravitational_force() + planet_velocity
	else:
		linear_velocity = Vector2.ZERO

func get_grabbed(following: Node2D) -> void:
	lock_rotation = false
	following_node = following

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

func _new_round(round: int) -> void:
	if round == spawn_round:
		visible = true
		$CollisionShape2D.disabled = false

func is_on_ground() -> bool:
	for ray in raycasts:
		if ray.is_colliding():
			return true
	
	return false

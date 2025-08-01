class_name Package
extends RigidBody2D


@export var spawn_round: int

@onready var gravity_component: GravityComponent = $"PackageArea"
@onready var animation: AnimationPlayer = $"AnimationPlayer"

@onready var raycasts: Array[RayCast2D] = [
	$"Raycasts/RayCast1",
	$"Raycasts/RayCast2",
	$"Raycasts/RayCast3",
	$"Raycasts/RayCast4",
]

func _ready() -> void:
	$LargePackage.visible = false
	
	var type: int = randi_range(1, 3)
	if type == 1:
		$SmallPackage.visible = true
		$CollisionShapeSmall.disabled = false
	if type == 2:
		$MediumPackage.visible = true
		$CollisionShapeMedium.disabled = false
	if type == 3:
		$LargePackage.visible = true
		$CollisionShapeLarge.disabled = false

func _physics_process(delta: float) -> void:
	gravity_component.update_gravity_force(delta)
	
	if !gravity_component.closest_gravity_area:
		return
	
	var planet_center: Vector2 = gravity_component.closest_gravity_area.global_position
	var upwards_angle: float = planet_center.angle_to_point(global_position)
	rotation = upwards_angle + PI/2

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !visible:
		return
	
	var planet_velocity: Vector2
	if gravity_component.closest_gravity_area:
		planet_velocity = gravity_component.closest_gravity_area.planet.velocity
	
	state.linear_velocity = gravity_component.get_gravitational_force() + planet_velocity

func get_grabbed() -> void:
	if get_parent() is World:
		get_parent().package_collected()
	animation.play("grab")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
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

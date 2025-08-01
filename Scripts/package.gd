class_name Package
extends RigidBody2D


@export var spawn_round: int

@onready var gravity_component: GravityComponent = $"GravityComponent"
@onready var animation: AnimationPlayer = $"AnimationPlayer"

@onready var raycasts: Array[RayCast2D] = [
	$"Raycasts/RayCast1",
	$"Raycasts/RayCast2",
	$"Raycasts/RayCast3",
	$"Raycasts/RayCast4",
]

#@onready var world: World = get_parent().get_parent()

func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	#world.new_round.connect(_new_round)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !visible:
		return
	
	state.linear_velocity = gravity_component.get_gravitational_force()

func get_grabbed() -> void:
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

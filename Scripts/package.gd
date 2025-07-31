class_name Package
extends RigidBody2D


@export var spawn_round: int

@onready var gravity_component: GravityComponent = $"GravityComponent"

@onready var animation: AnimationPlayer = $"AnimationPlayer"

@onready var world: World = get_parent().get_parent()

func _ready() -> void:
	visible = false
	$CollisionShape2D.disabled = true
	world.new_round.connect(_new_round)

func _physics_process(delta: float) -> void:
	if !visible:
		return
	gravity_component.physics()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if !visible:
		return
	gravity_component.integrate()

func get_grabbed() -> void:
	animation.play("grab")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

func _new_round(round: int) -> void:
	if round == spawn_round:
		visible = true
		$CollisionShape2D.disabled = false

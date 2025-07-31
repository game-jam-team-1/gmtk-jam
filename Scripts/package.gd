class_name Package
extends RigidBody2D

@onready var gravity_component: GravityComponent = $"GravityComponent"
@onready var animation: AnimationPlayer = $"AnimationPlayer"

func _physics_process(delta: float) -> void:
	gravity_component.physics()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	gravity_component.integrate()

func get_grabbed() -> void:
	animation.play("grab")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()

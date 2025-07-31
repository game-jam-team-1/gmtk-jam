class_name PlayerAnimation
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $"AnimatedSprite2D"

@onready var player: Player = get_parent()

func _ready() -> void:
	await get_tree().process_frame
	player.player_movement.thruster_boosted.connect(on_thruster_boost)

func _process(delta: float) -> void:
	if player.player_movement.is_grounded_movement:
		var dir: int = player.player_movement.grounded_movement_dir
		
		if dir == 1:
			animated_sprite.scale.x = -0.5
			animated_sprite.play("walk_loop")
			return
		
		if dir == -1:
			animated_sprite.scale.x = 0.5
			animated_sprite.play("walk_loop")
			return
		
		if dir == 0:
			animated_sprite.play("idle")
			return
	
	if player.player_movement.is_thruster_movement:
		
		if animated_sprite.animation == "start_fly" && animated_sprite.is_playing():
			return
		
		animated_sprite.play("fly_loop")

func on_thruster_boost() -> void:
	animated_sprite.play("start_fly")

class_name PlayerAudio
extends Node2D

@onready var player: Player = get_parent()

@onready var thruster: AudioStreamPlayer = $"Thruster"
@onready var walk: AudioStreamPlayer = $"Walk"
@onready var jump: AudioStreamPlayer = $"Jump"

var jumped: bool = false


func _process(delta: float) -> void:
	var player_movement: PlayerMovement = player.player_movement
	
	if player_movement.is_thruster_on && !thruster.playing:
		thruster.play()
	if ((!player_movement.is_thruster_on && thruster.playing) ||
	(player_movement.is_grounded_movement)):
		thruster.stop()
	
	if abs(player_movement.grounded_movement_dir) != 0 && !walk.playing && player.is_on_ground():
		walk.play()
	if player_movement.grounded_movement_dir == 0 && walk.playing || !player.is_on_ground():
		walk.stop()
	
	if player_movement.just_jumped:
		jumped = true
	
	if jumped && player.is_on_ground():
		jump.play(0.15)
		jumped = false

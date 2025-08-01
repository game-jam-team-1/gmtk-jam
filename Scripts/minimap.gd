class_name Minimap
extends Node2D

const scale_factor: float = 100.0

@onready var world: World = get_parent().get_parent().get_parent()
@onready var player: Player = get_parent().get_parent()

func _process(delta: float) -> void:
	queue_redraw()

func _convert_to_local(pos: Vector2):
	var converted: Vector2 = (pos - player.global_position) / scale_factor
	if converted.x > 60 || converted.x < -60 || converted.y > 60 || converted.y < -60:
		return Vector2.INF
	return converted

func _get_alpha(local_pos: Vector2) -> float:
	return 1 - local_pos.length() / 65

func _draw() -> void:
	var planets: Array[Planet]
	var enemies: Array[Node2D]
	var packages: Array[Package]
	
	for node in world.get_children():
		if node is Planet:
			planets.append(node)
		if node is CrawlerEnemy:
			enemies.append(node)
		if node is ShipEnemy:
			enemies.append(node)
		if node is Package:
			packages.append(node)
	
	for planet in planets:
		var local: Vector2 = _convert_to_local(planet.global_position)
		draw_circle(local, planet.radius / scale_factor, Color(1, 0.5, 0.3, _get_alpha(local)))
	for enemy in enemies:
		var local: Vector2 = _convert_to_local(enemy.global_position)
		draw_circle(local, 2.0, Color(1, 0, 0, _get_alpha(local)))
	for package in packages:
		var local: Vector2 = _convert_to_local(package.global_position)
		draw_circle(local, 2.0, Color(166/255.0,38/255.0,84/255.0))
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)

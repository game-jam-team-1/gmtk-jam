extends Node2D


func play_tutorial() -> void:
	stop_all()
	$"Tutorial".play()

func play_level1() -> void:
	stop_all()
	$"Level1".play()

func play_level2() -> void:
	stop_all()
	$"Level2".play()

func play_level3() -> void:
	stop_all()
	$"Level3".play()


func stop_all() -> void:
	$"Tutorial".stop()
	$"Level1".stop()
	$"Level2".stop()
	$"Level3".stop()

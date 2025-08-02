class_name LevelSelectButton
extends TextureButton


func _process(delta: float) -> void:
	if is_hovered():
		modulate = Color.WEB_GRAY
	else:
		modulate = Color.WHITE

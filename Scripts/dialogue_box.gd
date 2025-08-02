class_name DialogueBox
extends Control

signal finished

var is_writing_text: bool = false
var writing_text: String
var queue: Array[String]
var index: int = 0

func animate_writing_text(text: String) -> void:
	index = 0
	is_writing_text = true
	visible = true
	writing_text = text
	$Timer.start()

func text_chain(chain: Array[String]) -> void:
	index = 0
	animate_writing_text(chain[0])
	chain.pop_at(0)
	queue = chain

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("dismiss_dialogue"):
		if is_writing_text:
			index = writing_text.length()
		elif queue.is_empty():
			visible = false
			finished.emit()
		else:
			text_chain(queue)
	
	if !is_writing_text:
		return
	
	if $Timer.time_left < 0.02:
		index += 1
	
	if index == writing_text.length() + 1:
		is_writing_text = false
		return
	
	$Label.text = writing_text.substr(0, index)

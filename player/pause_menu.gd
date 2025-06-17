extends Control
class_name PauseMenu

func _ready() -> void:
	unpause()


func pause() -> void:
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func unpause() -> void:
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()

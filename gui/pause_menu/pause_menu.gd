extends Control
class_name PauseMenu

@export var player: Player

var paused: bool

func _ready() -> void:
	unpause()

func pause() -> void:
	paused = true
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.can_input = false
	#get_tree().paused = true

func unpause() -> void:
	paused = false
	hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player.can_input = true
	#get_tree().paused = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		print("move pause menu out of player script.")
		if paused:
			unpause()
		else:
			pause()

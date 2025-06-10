extends Marker3D
class_name PlayerHead

@export var player: CharacterBody3D
@export var mouse_sensitivity: float = .004

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		
		var delta_rotation: Vector2 = -event.relative * mouse_sensitivity
		
		# yaw
		player.rotate_y(delta_rotation.x)
		
		# pitch
		var new_rotation_x: float = delta_rotation.y + rotation.x
		new_rotation_x = clampf(new_rotation_x, - PI / 2, PI / 2)
		rotation.x = new_rotation_x

extends CharacterBody3D
class_name Player


var state: STATE = STATE.FLY
enum STATE {
	FLY,
	GROUNDED,
}
var can_input: bool = true


@export_group("Nodes")
@export var head: Marker3D
@export var voxel_interaction: VoxelInteraction
@export_group("Vars")
@export var mouse_sensitivity: float = .004
@export var fly_speed: float = 10
@export var ground_speed: float = 7.5
@export var jump_velocity: float = 4.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	match state:
		STATE.GROUNDED:
			
			if not is_on_floor():
				velocity += get_gravity() * delta
			
			
			var input_dir := Input.get_vector("left", "right", "forward", "back")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if not can_input:
				direction = Vector3.ZERO
			
			if direction:
				velocity.x = direction.x * ground_speed
				velocity.z = direction.z * ground_speed
			else:
				velocity.x = move_toward(velocity.x, 0, ground_speed)
				velocity.z = move_toward(velocity.z, 0, ground_speed)
			
			move_and_slide()
		
		
		STATE.FLY:
			var input_dir := Input.get_vector("left", "right", "forward", "back")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if not can_input:
				direction = Vector3.ZERO
			
			if direction:
				velocity.x = direction.x * fly_speed
				velocity.z = direction.z * fly_speed
			else:
				velocity.x = 0
				velocity.z = 0
			
			var y_dir := Input.get_axis("crouch", "jump")
			if not can_input:
				y_dir = 0
			velocity.y = y_dir * fly_speed
			
			move_and_slide()

#func jump() -> void:
	#if state == STATE.GROUNDED and is_on_floor():
		#velocity.y = jump_velocity


func _input(event: InputEvent) -> void:
	
	
	if not can_input:
		return
	
	if event.is_action_pressed("lmb"):
		voxel_interaction.lmb()
		
	elif event.is_action_pressed("rmb"):
		voxel_interaction.rmb()
	
	elif event.is_action_pressed("mmb"):
		voxel_interaction.mmb()
	
	#elif event.is_action_pressed("jump"):
		#jump()
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var delta_rotation: Vector2 = -event.relative * mouse_sensitivity
		
		# yaw, whole character
		rotate_y(delta_rotation.x)
		
		# pitch, head only
		var new_rotation_x: float = delta_rotation.y + head.rotation.x
		new_rotation_x = clampf(new_rotation_x, - PI / 2, PI / 2)
		head.rotation.x = new_rotation_x

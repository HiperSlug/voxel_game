extends CharacterBody3D
class_name Player



const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@export var head: PlayerHead

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	# Get head's forward direction, flattened on XZ
	var head_forward := head.global_transform.basis.z
	head_forward.y = 0
	head_forward = head_forward.normalized()

	# Get right direction on the horizontal plane
	var head_right := head.global_transform.basis.x
	head_right.y = 0
	head_right = head_right.normalized()

	# Combine input on flattened basis
	var direction := (head_right * input_dir.x + head_forward * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

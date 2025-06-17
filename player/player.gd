extends CharacterBody3D
class_name Player


var state: STATE = STATE.FLY
enum STATE {
	NORMAL,
	FLY,
}

var can_input: bool = true
var can_open_inventory: bool = true
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var head: Marker3D
@export var voxel_interaction: VoxelInteraction
@export var inventory_gui: InventoryGUI
@export var mouse_sensitivity: float = .004
@export var fly_speed: float = 10



func _physics_process(delta: float) -> void:
	match state:
		STATE.NORMAL:
			
			if not is_on_floor():
				velocity += get_gravity() * delta
			
			
			var input_dir := Input.get_vector("left", "right", "forward", "back")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if not can_input:
				direction = Vector3.ZERO
			
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
			
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


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#_on_chat_gui_start_chatting()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("inventory") and can_open_inventory:
		if inventory_gui.is_inventory_open():
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			can_input = true
			inventory_gui.close_creative_inventory()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			can_input = false
			inventory_gui.open_creative_inventory()
	
	
	if not can_input:
		return
	
	if event.is_action_pressed("destroy_voxel"):
		voxel_interaction.try_remove_pointed()
		
	elif event.is_action_pressed("place_voxel"):
		voxel_interaction.try_place_pointed()
	
	elif event.is_action_pressed("jump") and is_on_floor():
		if is_on_floor():
			velocity.y = JUMP_VELOCITY

	elif event.is_action_pressed("crouch"):
		if state == STATE.NORMAL:
			pass
	
	
	
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var delta_rotation: Vector2 = -event.relative * mouse_sensitivity
		
		# yaw
		rotate_y(delta_rotation.x)
		
		# pitch
		var new_rotation_x: float = delta_rotation.y + head.rotation.x
		new_rotation_x = clampf(new_rotation_x, - PI / 2, PI / 2)
		head.rotation.x = new_rotation_x
	
	elif event.is_action_pressed("next_slot"):
		#$PlayerHead/CrosshairRayCast.target_position.z += 1
		inventory_gui.next_slot()
		return
		
	elif event.is_action_pressed("last_slot"):
		#$PlayerHead/CrosshairRayCast.target_position.z -= 1
		inventory_gui.last_slot()
		return
	
	#elif event.is_action_pressed("pick_block"):
		#var sel_voxel: Vector3i = voxel_interaction.get_selected_voxel()
		#print("pick_block at", sel_voxel)
	
	for i: int in range(10):
		
		var slot_string: String = "slot_{0}".format([str(i + 1)])
		if event.is_action_pressed(slot_string):
			inventory_gui.select_slot(i)
			return
	
	



func _on_chat_gui_done_chatting() -> void:
	can_input = true
	can_open_inventory = true


func _on_chat_gui_start_chatting() -> void:
	can_input = false
	can_open_inventory = false

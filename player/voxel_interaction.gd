extends Node
class_name VoxelInteraction

@export var crosshair_raycast: RayCast3D
@export var inventory: Inventory
@export var inventory_gui: InventoryGUI
@onready var voxel_tool: VoxelTool = get_tree().get_first_node_in_group("voxel_terrain").get_voxel_tool()
@onready var item_handler: ItemHandler = get_tree().get_first_node_in_group("item_handler")

func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func get_pointed_voxel_position() -> Vector3i:
	if crosshair_raycast.is_colliding():
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		collision_point -= crosshair_raycast.get_collision_normal() * .5
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		return voxel_position
	else:
		var length: float = -crosshair_raycast.target_position.z
		var direction: Vector3 = -crosshair_raycast.global_basis.z
		var position: Vector3 = length * direction
		var voxel_position: Vector3i = Vector3i(floor(position))
		return voxel_position

func get_pointed_voxel() -> StringName:
	var position: Vector3i = get_pointed_voxel_position()
	var model_index: int = voxel_tool.get_voxel(position)
	var block_name: StringName = Block.get_name_from_index(model_index)
	return block_name


func try_remove_pointed() -> void:
	
	# if colliding
	if crosshair_raycast.is_colliding():
		
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		collision_point -= crosshair_raycast.get_collision_normal() * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# set air
		remove_voxel(voxel_position)

func try_place_pointed() -> void:
	
	if crosshair_raycast.is_colliding():
		
		# get voxel position.
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		var collision_normal: Vector3 = crosshair_raycast.get_collision_normal()
		collision_point += collision_normal * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# has an item
		var slot_index: int = inventory_gui.selected_hotbar_slot
		if inventory.is_slot_empty(slot_index):
			return
		
		# is a block
		var item: Item = inventory.inventory_slots[slot_index].item
		if not item is BlockItem:
			return
		
		var block_name: StringName = item.block_name
		if block_name == &"air":
			print("mine air")
			return
		
		# setting any inital attributes
		var attributes: Dictionary = {}
		for attribute: VoxelBlockyAttribute in item.get_block_attributes():
			if attribute is VoxelBlockyAttributeAxis:
				
				match abs(collision_normal):
					Vector3.FORWARD:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_Z
					Vector3.UP:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_Y
					Vector3.RIGHT:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_X
				
			elif attribute is VoxelBlockyAttributeDirection:
				
				match collision_normal:
					Vector3.FORWARD:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_Z
					Vector3.UP:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_Y
					Vector3.RIGHT:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_X
					Vector3.BACK:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_Z
					Vector3.DOWN:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_Y
					Vector3.LEFT:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_X
				
			elif attribute is VoxelBlockyAttributeRotation:
				printerr("No rotation handling")
		
		
		# get index
		var index: int
		
		match attributes.size():
			0:
				index = Block.block_library.get_model_index_default(block_name)
			1:
				index = Block.block_library.get_model_index_single_attribute(block_name, attributes.values()[0])
			_:
				index = Block.block_library.get_model_index_with_attributes(block_name, attributes)
		
		
		# place and remove from inventory
		inventory.remove_amount_from_slot(slot_index, 1)
		add_voxel(voxel_position, index)


@export var block_group: LookupGroup

var air_index: int = Block.block_library.get_model_index_default(&"air")

func remove_voxel(voxel_position: Vector3i) -> void:
	
	var model_index: int = voxel_tool.get_voxel(voxel_position)
	var block_name: StringName = Block.get_name_from_index(model_index)
	voxel_tool.set_voxel(voxel_position, air_index)
	
	if block_name == &"air":
		print("remove air")
		return
	
	if block_group.res_key_exists(block_name):
		var drops: Array[Item] = block_group.get_res_key(block_name).drop._get_drop()
		
		for item: Item in drops:
			var item_position: Vector3 = Vector3(voxel_position) + Vector3(.5, .5, .5)
			
			item_handler.add_items(item_position, item)
			
	

func add_voxel(voxel_position: Vector3i, type: int) -> void:
	voxel_tool.set_voxel(voxel_position, type)

extends Node
class_name VoxelInteraction

@export var head: Marker3D
@export var inventory_gui: InventoryGUI
@onready var voxel_tool: VoxelTool = get_tree().get_first_node_in_group("voxel_terrain").get_voxel_tool()
var block_library: BlockLibrary = preload("res://data/blocks/block_library.tres")

const relative_vectors: Array[Vector3i] = [
	Vector3i.UP,
	Vector3i.DOWN,
	Vector3i.FORWARD,
	Vector3i.BACK,
	Vector3i.LEFT,
	Vector3i.RIGHT,
]


func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

var last_temporary_mesh: TemporaryMesh
func _process(_delta: float) -> void:
	if last_temporary_mesh:
		last_temporary_mesh.queue_free()
	
	var voxel_raycast_result = voxel_tool.raycast(head.global_position, -head.global_basis.z, 50, 1 << 4)
	if voxel_raycast_result == null:
		return
	
	
	
	last_temporary_mesh = TemporaryMesh.create_aabb_mesh(voxel_raycast_result.position, voxel_raycast_result.position)
	var fx_node: Node = get_tree().get_first_node_in_group("fx")
	fx_node.add_child(last_temporary_mesh)
	

func try_remove_pointed() -> void:
	var voxel_raycast_result = voxel_tool.raycast(head.global_position, -head.global_basis.z, 50, 1 << 4)
	if voxel_raycast_result == null:
		return
	voxel_raycast_result = voxel_raycast_result as VoxelRaycastResult
	
	var voxel_position: Vector3i = voxel_raycast_result.position
	voxel_tool.set_voxel(voxel_position, 0)
	
	for vector in relative_vectors:
		var update_position: Vector3i = voxel_position + vector
		block_update(update_position)

func try_place_pointed() -> void:
	var voxel_raycast_result = voxel_tool.raycast(head.global_position, -head.global_basis.z, 50, 1 << 4)
	if voxel_raycast_result == null:
		return
	voxel_raycast_result = voxel_raycast_result as VoxelRaycastResult
	
	# has an item
	var slot: InventorySlotGUI = inventory_gui.get_selected_slot()
	if slot.item == null:
		return
	
	# is a block
	if not slot.item is BlockItem:
		return
	
	var voxel_position: Vector3i = voxel_raycast_result.previous_position
	
	var block: Block = block_library.get_block_s(slot.item.block_name)
	if block.mode == Block.MODE.BIOME:
		var biome := MyGenerator.get_biome(voxel_position)
		match biome:
			MyGenerator.BIOME.PLAINS:
				block = block.multi_blocks[0]
			MyGenerator.BIOME.TUNDRA:
				block = block.multi_blocks[1]
	
	if block.mode == Block.MODE.MULTI:
		var replaced_voxel_index: int = voxel_tool.get_voxel(voxel_raycast_result.position)
		
		var replaced: bool = false
		for i: int in range(block.multi_blocks.size()):
			if replaced_voxel_index in block.multi_blocks[i].all_indices():
				var next_index: int = i + 1
				if next_index >= block.multi_blocks.size():
					next_index = 0
				block = block.multi_blocks[next_index]
				voxel_position = voxel_raycast_result.position
				replaced = true
				break
		
		if not replaced:
			block = block.multi_blocks[0]
	
	
	match block.support_type:
		Block.SUPPORT.BOTTOM:
			var position_beneath: Vector3i = voxel_position + Vector3i.DOWN
			var voxel_beneath: int = voxel_tool.get_voxel(position_beneath)
			
			if not block_library.get_block_i(voxel_beneath).can_support:
				return
			
		Block.SUPPORT.BOTTOM_OR_SIDES:
			pass
	
	
	
	
	var index: int = 0
	match block.mode:
			Block.MODE.SINGLE:
				index = block.index
			Block.MODE.AXIS: 
				match voxel_raycast_result.normal.abs():
					Vector3.BACK:
						index = block.index_z
					Vector3.UP:
						index = block.index_y
					Vector3.RIGHT:
						index = block.index_x
					_:
						index = block.index_y
			Block.MODE.HORIZONTAL_DIRECTION:
				var backward := head.global_basis.z
				if abs(backward.x) > abs(backward.z):
					if backward.x > 0:
						index = block.index_pos_x
					else:
						index = block.index_neg_x
				else: # abs(backward.x) < abs(backward.z)
					if backward.z > 0:
						index = block.index_neg_z
					else:
						index = block.index_pos_z
	
	
	voxel_tool.set_voxel(voxel_position, index)
	for vector in relative_vectors:
		var update_position: Vector3i = voxel_position + vector
		block_update(update_position)


func block_update(position: Vector3i) -> void:
	var voxel: int = voxel_tool.get_voxel(position)
	if voxel == 0:
		return
	
	var block: Block = block_library.get_block_i(voxel)
	
	match block.support_type:
		Block.SUPPORT.BOTTOM:
			var position_beneath: Vector3i = position + Vector3i.DOWN
			var voxel_beneath: int = voxel_tool.get_voxel(position_beneath)
			if voxel_beneath == 0:
				voxel_tool.set_voxel(position, 0)
				return
			
			if not block_library.get_block_i(voxel_beneath).can_support:
				voxel_tool.set_voxel(position, 0)
		Block.SUPPORT.BOTTOM_OR_SIDES:
			pass

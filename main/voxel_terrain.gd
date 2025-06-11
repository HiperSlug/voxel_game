extends VoxelTerrain
class_name MinecraftTerrain

var voxel_tool := get_voxel_tool()

@export var block_group: LookupGroup
@export var item_handler: ItemHandler

func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func remove_voxel(voxel_position: Vector3i) -> void:
	
	var model_index: int = voxel_tool.get_voxel(voxel_position)
	var block_name: StringName = BlockIndex.get_name_from_index(model_index)
	
	var drops: Array[Item] = block_group.get_resource_from_property(block_name).drop._get_drop()
	
	for item: Item in drops:
		var item_position: Vector3 = Vector3(voxel_position) + Vector3(.5, .5, .5)
		
		item_handler.add_items(item_position, item)
		
		voxel_tool.set_voxel(voxel_position, BlockIndex.AIR)

func add_voxel(voxel_position: Vector3i, type: int) -> void:
	voxel_tool.set_voxel(voxel_position, type)

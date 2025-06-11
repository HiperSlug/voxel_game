extends RefCounted
class_name TreeGenerator

static var trunk_height: int = 6
static var log_type: int = load("res://data/voxel_blocks/blocks_library.tres").get_model_index_single_attribute(&"log", VoxelBlockyAttributeAxis.AXIS_Y)
static var channel := VoxelBuffer.CHANNEL_TYPE

static func generate() -> Structure:
	
	var voxels: Dictionary = {}
	
	# Trunk
	for y: int in trunk_height:
		var pos: Vector3i = Vector3(0, y, 0)
		voxels[pos] = log_type
	
	
	# Creating structure
	var aabb := AABB()
	for pos: Vector3i in voxels:
		aabb = aabb.expand(pos)
	
	var structure: Structure = Structure.new()
	structure.offset = -aabb.position
	
	var buffer := structure.voxels
	buffer.create(int(aabb.size.x) + 1, int(aabb.size.y) + 1, int(aabb.size.z) + 1)
	
	for pos: Vector3i in voxels:
		var rel_pos: Vector3i = pos + structure.offset
		var type = voxels[pos]
		buffer.set_voxel(type, rel_pos.x, rel_pos.y, rel_pos.z, channel)

	return structure

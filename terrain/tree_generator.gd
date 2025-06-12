extends RefCounted
class_name TreeGenerator

# voxel index
static var blocks: LookupGroup = preload("res://data/group_block.tres")
static var log_index: int = blocks.get_resource_from_property(&"log").get_block_index().get_index_with_attributes({
	"axis" : VoxelBlockyAttributeAxis.AXIS_Y,
})

# channel
static var channel := VoxelBuffer.CHANNEL_TYPE

static func generate(_rng: RandomNumberGenerator) -> Structure:
	
	
	var voxels: Dictionary = {}
	
	# Trunk
	voxels[Vector3i(0, 0, 0)] = log_index
	
	
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

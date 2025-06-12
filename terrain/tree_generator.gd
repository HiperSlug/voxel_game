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
	
	
	return load("res://data/structure/test.tres")

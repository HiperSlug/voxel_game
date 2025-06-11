extends Resource
class_name BlockIndex

@export var name: StringName

static var blocks_library: VoxelBlockyTypeLibrary = preload("res://data/voxel_blocks/blocks_library.tres")



# GET INDEXS
var base_index_cache: int = -1
func get_base_index() -> int:
	if base_index_cache != -1:
		return base_index_cache
	
	var index: int = blocks_library.get_model_index_default(name)
	base_index_cache = index
	return index

var single_attribute_cache: Dictionary[Variant, int] = {}
func get_index_with_attribute(attribute: Variant) -> int:
	if attribute in single_attribute_cache:
		return single_attribute_cache[attribute]
	
	var index: int = blocks_library.get_model_index_single_attribute(name, attribute)
	single_attribute_cache[attribute] = index
	return index

func get_index_with_attributes(attributes: Dictionary) -> int:
	return blocks_library.get_model_index_with_attributes(name, attributes)

# GET NAME
static func get_name_from_index(index: int) -> StringName:
	return blocks_library.get_type_name_and_attributes_from_model_index(index)[0]

# GET ATTRIBUTES
var cached_attributes
func get_attributes() -> Array[VoxelBlockyAttribute]:
	if cached_attributes != null:
		return cached_attributes
	
	for block: VoxelBlockyType in blocks_library.types:
		if block.unique_name == name:
			cached_attributes = block.attributes
			return block.attributes
	
	printerr("invalid blockindex name")
	return []

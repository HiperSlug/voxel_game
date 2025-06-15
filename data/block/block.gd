extends Resource
class_name Block

@export var name: StringName
@export var drop: Drop


func get_drops() -> Array[Item]:
	if drop == null:
		return []
	else:
		return drop._get_drop()

const block_library: VoxelBlockyTypeLibrary = preload("res://data/voxel_library/blocks_library.tres")

static func get_name_from_index(index: int) -> StringName:
	return block_library.get_type_name_and_attributes_from_model_index(index)[0]

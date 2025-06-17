extends Item
class_name BlockItem

@export var block_name: StringName


#func get_block_index() -> int:
	#return Block.block_library.get_model_index_default(block_name)
#
#func get_block_attributes() -> Array[VoxelBlockyAttribute]:
	#return Block.block_library.get_type_from_name(block_name).attributes

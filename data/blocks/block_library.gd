@tool
extends Resource
class_name BlockLibrary


@export var blocks: Array[Block]:
	set(value):
		blocks = value
		update_dictionary()
@export var voxel_library: VoxelBlockyLibrary

var blocks_dictionary: Dictionary[StringName, Block] = {}

func get_block(name: StringName) -> Block:
	
	if blocks_dictionary.has(name):
		return blocks_dictionary[name]
	
	update_dictionary()
	
	return blocks_dictionary.get(name, null)

func update_dictionary() -> void:
	for block: Block in blocks:
		blocks_dictionary[block.name] = block

@tool
extends Resource
class_name BlockLibrary


@export var blocks: Array[Block]:
	set(value):
		blocks = value
		update_dictionary()
		cache_all_indexes()
		
@export var voxel_library: VoxelBlockyLibrary

var blocks_dictionary: Dictionary[StringName, Block] = {}

func update_dictionary() -> void:
	for block: Block in blocks:
		blocks_dictionary[block.name] = block

func get_block_s(name: StringName) -> Block:
	
	if blocks_dictionary.has(name):
		return blocks_dictionary[name]
	
	update_dictionary()
	
	return blocks_dictionary.get(name, null)

func cache_all_indexes() -> void:
	for block: Block in blocks:
		for index: int in block.all_indices():
			i_to_block[index] = block


var i_to_block: Dictionary[int, Block] = {}
func get_block_i(index: int) -> Block:
	
	var dict_block = i_to_block.get(index, null)
	if dict_block != null:
		return dict_block
	
	for block: Block in blocks:
		var indices: Array[int] = block.all_indices()
		if indices.has(index):
			i_to_block[index] = block
			return block
	return null

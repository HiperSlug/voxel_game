extends RefCounted
class_name IndexHandler

static var index_dictionary: Dictionary = {}

static func get_block_index(name: StringName) -> BlockIndex:
	if name in index_dictionary.keys():
		return index_dictionary[name]
	
	else:
		var block_index: BlockIndex = BlockIndex.new(name)
		index_dictionary[name] = block_index
		
		return block_index

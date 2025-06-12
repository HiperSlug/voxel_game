extends RefCounted
class_name IndexHandler

static var index_dictionary: Dictionary = {}

static func get_block_index(name: StringName) -> BlockIndexer:
	if name in index_dictionary.keys():
		return index_dictionary[name]
	
	else:
		var block_indexer: BlockIndexer = BlockIndexer.new(name)
		index_dictionary[name] = block_indexer
		
		return block_indexer

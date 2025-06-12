extends Item
class_name BlockItem

@export var block_name: StringName

func get_block_index() -> BlockIndexer:
	return IndexHandler.get_block_index(block_name)

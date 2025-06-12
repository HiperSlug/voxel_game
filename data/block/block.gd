extends Resource
class_name Block

@export var name: StringName
@export var drop: Drop

func get_block_index() -> BlockIndexer:
	return IndexHandler.get_block_index(name)

func get_drops() -> Array[Item]:
	if drop == null:
		return []
	else:
		return drop._get_drop()

extends Resource
class_name Drop

# DropItem, DropChance, DropPool, DropRange

func _get_drop() -> Array[Item]:
	printerr("DROP class is not meant to be used")
	return [Item.new()]

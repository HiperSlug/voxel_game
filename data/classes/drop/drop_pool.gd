extends Drop
class_name DropPool

@export var drops: Array[Drop] = []

func _get_drop() -> Array[Item]:
	var items: Array[Item]
	
	for drop: Drop in drops:
		items.append_array(drop._get_drop())
	
	return items

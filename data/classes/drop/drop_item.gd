extends Drop
class_name DropItem

@export var item: Item
@export var amount: int = 1

func _get_drop() -> Array[Item]:
	var items: Array[Item] = []
	
	for i: int in range(amount):
		items.append(item)
	
	return items

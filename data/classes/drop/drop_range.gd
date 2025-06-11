extends Drop
class_name DropRange

@export var item: Item
@export var min: int = 1
@export var max: int = 5

func _get_drop() -> Array[Item]:
	
	var extent: int = (max - min) + 1
	var amount_unweighted: int = randi() % extent
	var amount: int = amount_unweighted + min
	
	var items: Array[Item]
	
	for i: int in range(amount):
		items.append(item)
	
	return items

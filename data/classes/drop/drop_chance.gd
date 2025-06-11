extends Drop
class_name DropChance

@export var drop: Drop
@export var chance: float = .5

func _get_drop() -> Array[Item]:
	
	if randf() < chance:
		return drop._get_drop()
	
	return []

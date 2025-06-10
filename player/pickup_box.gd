extends Area3D
class_name PickupBox

@export var inventory: Inventory

func pickup_item(item: Item, count: int) -> bool:
	return inventory.add_items(item, count)

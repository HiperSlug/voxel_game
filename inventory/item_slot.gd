extends RefCounted
class_name ItemSlot

var item: Item
var amount: int

signal amount_changed(new_amount: int)
signal item_changed(new_item: Item)

func change_amount(delta_amount: int) -> int:
	return set_amount(amount + delta_amount)

func set_amount(new_amount: int) -> int:
	var left_over: int = new_amount - item.stack_size
	left_over = max(left_over, 0)
	
	new_amount = clampi(new_amount, 0, item.stack_size)
	if new_amount != amount:
		amount_changed.emit(new_amount)
	
	amount = new_amount
	
	return left_over

func set_item(new_item: Item) -> void:
	item = new_item
	item_changed.emit(item)

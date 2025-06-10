extends RefCounted
class_name InventorySlot

signal amount_changed(new_amount: int)
signal item_changed(new_item: Item)
signal empty()

var is_empty: bool = true
var is_full: bool = false

var item: Item
var amount: int = 0

static var max_amount: int = 999

func change_count(delta_amount: int) -> int:
	return set_count(amount + delta_amount)

func set_count(new_amount: int) -> int:
	
	var left_over_amount: int = 0
	
	amount_changed.emit(new_amount)
	
	if new_amount <= 0:
		is_empty = true
		is_full = false
		empty.emit()
		left_over_amount = -new_amount
		
	elif new_amount > max_amount:
		is_full = true
		is_empty = false
		left_over_amount = new_amount - max_amount
	
	else:
		is_full = false
		is_empty = false
	
	amount = clampi(new_amount, 0, max_amount)
	
	
	
	return left_over_amount

func set_item(new_item: Item) -> void:
	item = new_item
	item_changed.emit(item)

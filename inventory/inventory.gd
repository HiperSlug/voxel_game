extends Node
class_name Inventory

var inventory_slots: Array[InventorySlot] = []
var inventory_size: int = 10


func _ready() -> void:
	initalize_slots()

func initalize_slots() -> void:
	
	inventory_slots.resize(inventory_size)
	for i: int in inventory_slots.size():
		inventory_slots[i] = InventorySlot.new()

func add_items(item: Item, amount: int) -> int:
	for slot: InventorySlot in inventory_slots:
		if slot.is_empty and not slot.is_full:
			continue
			
		if slot.item == item:
			var left_over_amount: int = slot.change_count(amount)
			amount = left_over_amount
			
		if amount == 0:
			return 0
	
	for slot: InventorySlot in inventory_slots:
		if slot.is_empty:
			slot.set_item(item)
			var left_over_amount: int = slot.set_count(amount)
			amount = left_over_amount
			
		if amount == 0:
			return 0
	
	return amount


func get_count_at_slot(slot_index: int) -> int:
	return inventory_slots[slot_index].count

func remove_amount_from_slot(slot_index: int, amount: int) -> void:
	inventory_slots[slot_index].change_count(-amount)

func is_slot_empty(index: int) -> bool:
	return inventory_slots[index].is_empty

extends Node
class_name Inventory

var inventory_slots: Array[ItemSlot] = []
var inventory_size: int = 10


func _ready() -> void:
	inventory_slots.resize(inventory_size)
	for i: int in inventory_slots.size():
		inventory_slots[i] = ItemSlot.new()

func add_items(item: Item, amount: int) -> bool:
	for slot: ItemSlot in inventory_slots:
		if slot.item == item:
			var leftover: int = slot.change_amount(amount)
			amount = leftover
		
		if amount == 0:
			return 0
	
	for slot: ItemSlot in inventory_slots:
		if slot.amount == 0:
			slot.item = item
			var leftover: int = slot.change_amount(amount)
			amount = leftover
			
			if amount == 0:
				return 0
	
	return amount


func get_count_at_slot(slot_index: int) -> int:
	return inventory_slots[slot_index].count

func remove_amount_from_slot(slot_index: int, amount: int) -> void:
	inventory_slots[slot_index].change_amount(-amount)

func is_slot_empty(index: int) -> bool:
	return inventory_slots[index].amount == 0

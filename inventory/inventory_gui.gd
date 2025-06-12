extends Control
class_name InventoryGUI

@export var inventory: Inventory
@export var hotbar: HBoxContainer
var selected_hotbar_slot: int = 0

func _ready() -> void:
	connect_inventory_slots(inventory.inventory_slots)
	select_slot(selected_hotbar_slot)

func connect_inventory_slots(inventory_slots: Array[InventorySlot]) -> void:
	
	for i: int in range(inventory_slots.size()):
		
		# hotbar
		if i < hotbar.get_child_count():
			
			var item_slot: InventorySlot = inventory_slots[i]
			var inv_slot_gui: PanelContainer = hotbar.get_child(i)
			inv_slot_gui.set_item_slot(item_slot)


func next_slot() -> void:
	select_slot(selected_hotbar_slot + 1)

func last_slot() -> void:
	select_slot(selected_hotbar_slot - 1)

func select_slot(new_index: int) -> void:
	new_index = new_index % hotbar.get_child_count()
	
	
	var slot_gui_old: PanelContainer = hotbar.get_child(selected_hotbar_slot)
	slot_gui_old.theme_type_variation = &"InventorySlot"
	
	selected_hotbar_slot = new_index
	
	var slot_gui_new: PanelContainer = hotbar.get_child(selected_hotbar_slot)
	slot_gui_new.theme_type_variation = &"SelInventorySlot"

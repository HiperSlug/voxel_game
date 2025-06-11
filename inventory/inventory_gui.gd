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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_slot"):
		select_slot(selected_hotbar_slot + 1)
		return
		
	elif event.is_action_pressed("last_slot"):
		select_slot(selected_hotbar_slot - 1)
		return
	
	
	for i: int in range(10):
		
		var slot_string: String = "slot_{0}".format([str(i + 1)])
		if event.is_action_pressed(slot_string):
			select_slot(i)
			return


func select_slot(new_index: int) -> void:
	new_index = new_index % hotbar.get_child_count()
	
	
	var slot_gui_old: PanelContainer = hotbar.get_child(selected_hotbar_slot)
	slot_gui_old.theme_type_variation = &"InventorySlot"
	
	selected_hotbar_slot = new_index
	
	var slot_gui_new: PanelContainer = hotbar.get_child(selected_hotbar_slot)
	slot_gui_new.theme_type_variation = &"SelInventorySlot"

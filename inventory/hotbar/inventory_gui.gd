extends Control
class_name InventoryGUI

@export var hotbar: HBoxContainer
var selected_hotbar_slot: int = 0

func _ready() -> void:
	select_slot(selected_hotbar_slot)
	close_creative_inventory()

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


@onready var creative_inventory: CreativeInventory = $CreativeInventory

func get_selected_slot() -> InventorySlotGUI:
	return hotbar.get_child(selected_hotbar_slot)

func open_creative_inventory() -> void:
	creative_inventory.show()

func close_creative_inventory() -> void:
	creative_inventory.hide()

func is_inventory_open() -> bool:
	return creative_inventory.visible

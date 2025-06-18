extends Control
class_name CreativeInventory

@export var item_group: LookupGroup
const GROUP_ITEM = preload("res://data/group_item.tres")
@export var section_container: Container
const INVENTORY_SECTION = preload("res://inventory/creative_inventory/inventory_section.tscn")

var group_to_section: Dictionary[StringName, PanelContainer] = {}
func _ready() -> void:
	var items: Array[Resource] = GROUP_ITEM.get_res_arr()
	
	for item: Item in items:
		var section = group_to_section.get(item.category, null)
		if section != null:
			section = section as Section
			section.add_item_slot(item)
			continue
		
		section = INVENTORY_SECTION.instantiate()
		section.set_section_name(item.category)
		section.add_item_slot(item)
		group_to_section[item.category] = section
		section_container.add_child(section)

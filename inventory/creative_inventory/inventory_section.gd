extends PanelContainer
class_name Section

@export var section_title: Label
@export var item_container: Container
func set_section_name(new_name: String) -> void:
	name = new_name
	section_title.text = new_name

const CREATIVE_ITEM_SLOT_scene = preload("res://inventory/creative_inventory/creative_item_slot.tscn")


func add_item_slot(item: Item) -> void:
	var item_slot: CreativeItemSlot = CREATIVE_ITEM_SLOT_scene.instantiate()
	item_slot.item = item
	
	item_container.add_child(item_slot)

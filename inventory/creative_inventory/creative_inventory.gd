extends Control
class_name CreativeInventory

@export var item_group: LookupGroup
var creative_item_slot_scene: PackedScene = preload("res://inventory/creative_inventory/creative_item_slot.tscn")
@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	var items: Array[Resource] = item_group.get_res_arr()
	
	for item in items:
		var slot: CreativeItemSlot = creative_item_slot_scene.instantiate()
		slot.item = item
		grid_container.add_child(slot)

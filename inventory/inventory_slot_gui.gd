extends PanelContainer
class_name InventorySlotGUI

var item_slot: InventorySlot

@onready var texture_rect: TextureRect = $ItemTexture
@onready var count: Label = $Count


func set_item_slot(new_item_slot: InventorySlot) -> void:
	item_slot = new_item_slot
	
	item_slot.amount_changed.connect(on_item_slot_amount_changed)
	item_slot.item_changed.connect(on_item_slot_item_changed)
	item_slot.empty.connect(on_item_slot_empty)
	
	if item_slot.is_empty:
		return
	
	texture_rect.texture = item_slot.item.single_texturea
	count.text = str(item_slot.amount)
	

func on_item_slot_amount_changed(new_amount: int) -> void:
	count.text = str(new_amount)

func on_item_slot_item_changed(new_item: Item) -> void:
	texture_rect.texture = new_item.single_texture

func on_item_slot_empty() -> void:
	count.text = ""
	texture_rect.texture = null

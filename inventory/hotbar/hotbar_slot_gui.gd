extends PanelContainer
class_name InventorySlotGUI

@onready var item_texture: TextureRect = $ItemTexture
@onready var amount: Label = $Amount

var item_slot: ItemSlot

func set_item_slot(new_item_slot: ItemSlot) -> void:
	item_slot = new_item_slot
	item_slot.amount_changed.connect(on_amount_changed)
	item_slot.item_changed.connect(on_item_changed)

func on_amount_changed(new_amount: int) -> void:
	if new_amount == 0:
		item_texture.hide()
		amount.hide()
		return
	
	if new_amount == 1:
		item_texture.texture = item_slot.item.single_texture
	else:
		item_texture.texture = item_slot.item.multi_texture
	
	item_texture.show()
	amount.show()
	
	amount.text = str(new_amount)

func on_item_changed(new_item: Item) -> void:
	if item_slot.amount == 1:
		item_texture.texture = new_item.single_texture
	else:
		item_texture.texture = new_item.multi_texture

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	item_slot.set_item(data)
	item_slot.set_amount(999)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Item

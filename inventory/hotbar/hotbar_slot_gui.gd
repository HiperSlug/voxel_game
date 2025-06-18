extends PanelContainer
class_name InventorySlotGUI

@onready var item_texture: TextureRect = $ItemTexture

var item: Item

func set_item(new_item: Item) -> void:
	item = new_item
	tooltip_text = item.name
	item_texture.texture = item.single_texture

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	set_item(data)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Item

func clear_item() -> void:
	item = null
	item_texture.texture = null

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_voxel"):
		clear_item()

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(make_preview())
	var item_ := item
	clear_item()
	return item_

func make_preview() -> Node:
	var new_texture: TextureRect = item_texture.duplicate()
	new_texture.position = new_texture.size / 2
	return new_texture

extends PanelContainer
class_name CreativeItemSlot

@export var item: Item
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	if not item:
		return
	texture_rect.texture = item.single_texture
	tooltip_text = item.name

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(texture_rect.duplicate())
	return item

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_stack"):
		var hotbar: HBoxContainer = get_tree().get_first_node_in_group("hotbar")
		for slot: InventorySlotGUI in hotbar.get_children():
			if slot.item == null:
				slot.set_item(item)
				return

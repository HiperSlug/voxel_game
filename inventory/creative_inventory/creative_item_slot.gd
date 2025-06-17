extends PanelContainer
class_name CreativeItemSlot

@export var item: Item
@onready var texture_rect: TextureRect = $TextureRect

func _ready() -> void:
	texture_rect.texture = item.single_texture

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(texture_rect.duplicate())
	return item

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_stack"):
		var inventory: Inventory = get_tree().get_first_node_in_group("inventory")
		inventory.add_items(item, 999)

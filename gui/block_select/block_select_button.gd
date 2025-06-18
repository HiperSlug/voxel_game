@tool
extends Button
class_name BlockSelectButton

@export var block: Block
@onready var editor: VoxelEditor = get_tree().get_first_node_in_group("editor")

func _ready() -> void:
	if block:
		icon = block.texture

func _pressed() -> void:
	editor.switch_block(block)

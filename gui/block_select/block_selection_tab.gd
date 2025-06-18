extends PanelContainer
class_name TabGroup

var block_button_scene: PackedScene = preload("res://gui/block_select/block_select_button.tscn")
@export var grid_container: GridContainer

func add_block(block: Block) -> void:
	var block_button: BlockSelectButton = block_button_scene.instantiate()
	block_button.block = block
	
	tooltip_text = block.name
	
	grid_container.add_child(block_button)

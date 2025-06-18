extends TabContainer

@export var block_lib: BlockLibrary

var tab_scene: PackedScene = preload("res://gui/block_select/block_selection_tab.tscn")

func _ready() -> void:
	print("initalize block selection from block library")
	initalize_block_lib()

func initalize_block_lib() -> void:
	var group_to_tab: Dictionary = {}
	
	for block: Block in block_lib.blocks:
		
		if not group_to_tab.has(block.editor_group):
			var tab: TabGroup = tab_scene.instantiate()
			group_to_tab[block.editor_group] = tab
			tab.name = block.editor_group.capitalize()
			add_child(tab)
		
		group_to_tab[block.editor_group].add_block(block)

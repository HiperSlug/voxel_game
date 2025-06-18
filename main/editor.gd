extends Control
class_name VoxelEditor

# VoxelTool

enum TOOL {
	BOX,
	PATH,
	POINT,
	SPHERE,
	BUCKET, 
}
var tool: TOOL = TOOL.SPHERE

var block: Block
var index: int

func switch_block(new_block: Block) -> void:
	print(new_block.name)
	block = new_block
	index = block.index

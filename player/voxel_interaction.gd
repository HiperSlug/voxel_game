extends Node
class_name VoxelInteraction

@export var raycast: RayCast3D
@onready var voxel_tool: VoxelTool = get_tree().get_first_node_in_group("voxel_terrain").get_voxel_tool()
@onready var voxel_editor: VoxelEditor = get_tree().get_first_node_in_group("editor")


func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	voxel_tool.mode = VoxelTool.MODE_SET

func lmb() -> void:
	match voxel_editor.tool:
		voxel_editor.TOOL.BOX:
			pass
		voxel_editor.TOOL.PATH:
			pass
		voxel_editor.TOOL.POINT:
			if raycast.is_colliding():
				var collision_position := get_collision_vox_position(true)
				voxel_tool.value = 0
				voxel_tool.do_point(collision_position)
		voxel_editor.TOOL.SPHERE:
			if raycast.is_colliding():
				var collision_position := get_collision_vox_position()
				voxel_tool.value = 0
				voxel_tool.do_sphere(collision_position, 5)
		voxel_editor.TOOL.BUCKET:
			pass


func rmb() -> void:
	match voxel_editor.tool:
		voxel_editor.TOOL.BOX:
			pass
		voxel_editor.TOOL.PATH:
			pass
		voxel_editor.TOOL.POINT:
			if raycast.is_colliding():
				var collision_position := get_collision_vox_position()
				voxel_tool.value = voxel_editor.index
				voxel_tool.do_point(collision_position)
		voxel_editor.TOOL.SPHERE:
			if raycast.is_colliding():
				var collision_position := get_collision_vox_position()
				voxel_tool.value = voxel_editor.index
				voxel_tool.do_sphere(collision_position, 10)
		voxel_editor.TOOL.BUCKET:
			pass

func mmb() -> void:
	pass


func get_collision_vox_position(move_inside: bool = false) -> Vector3i:
	var point := raycast.get_collision_point()
	
	if move_inside:
		point -= raycast.get_collision_normal() * .5
	else:
		point += raycast.get_collision_normal() * .5
	
	var voxel_position := Vector3i(point.floor())
	
	return voxel_position

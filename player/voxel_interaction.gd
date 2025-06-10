extends Node
class_name VoxelInteraction

@export var crosshair_raycast: RayCast3D
@export var inventory: Inventory
@export var inventory_gui: InventoryGUI
@onready var voxel_terrain: VoxelTerrain = get_tree().get_first_node_in_group("voxel_terrain")
@onready var voxel_tool: VoxelTool = voxel_terrain.get_voxel_tool()
@export var blocks_library: VoxelBlockyTypeLibrary

func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _input(event: InputEvent) -> void:
	# Handle input in player and then deliniate it here later
	if event.is_action_pressed("destroy_voxel"):
		try_remove_pointed_voxel()
		
	elif event.is_action_pressed("place_voxel"):
		try_place_at_pointed()


func try_remove_pointed_voxel() -> void:
	
	# if colliding
	if crosshair_raycast.is_colliding():
		
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		collision_point -= crosshair_raycast.get_collision_normal() * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# set air
		voxel_tool.set_voxel(voxel_position, 0) 

func try_place_at_pointed() -> void:
	
	if crosshair_raycast.is_colliding():
		
		# get voxel position.
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		collision_point += crosshair_raycast.get_collision_normal() * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# get item
		var slot_index: int = inventory_gui.selected_hotbar_slot
		if inventory.is_slot_empty(slot_index):
			return
		var item_name: StringName = inventory.inventory_slots[slot_index].item.name.to_lower()
		var item_index: int = blocks_library.get_model_index_single_attribute(item_name, VoxelBlockyAttributeAxis.AXIS_Y)
		
		inventory.remove_amount_from_slot(slot_index, 1)
		
		voxel_tool.set_voxel(voxel_position, item_index)

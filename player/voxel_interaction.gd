extends Node
class_name VoxelInteraction

@export var crosshair_raycast: RayCast3D
@export var inventory: Inventory
@export var inventory_gui: InventoryGUI
@onready var voxel_terrain: MinecraftTerrain = get_tree().get_first_node_in_group("voxel_terrain")


func try_remove_pointed() -> void:
	
	# if colliding
	if crosshair_raycast.is_colliding():
		
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		collision_point -= crosshair_raycast.get_collision_normal() * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# set air
		voxel_terrain.remove_voxel(voxel_position)

func try_place_pointed() -> void:
	
	if crosshair_raycast.is_colliding():
		
		# get voxel position.
		var collision_point: Vector3 = crosshair_raycast.get_collision_point()
		var collision_normal: Vector3 = crosshair_raycast.get_collision_normal()
		collision_point += collision_normal * .5
		
		var voxel_position: Vector3i = Vector3i(floor(collision_point))
		
		# has an item
		var slot_index: int = inventory_gui.selected_hotbar_slot
		if inventory.is_slot_empty(slot_index):
			return
		
		# is a block
		var item: Item = inventory.inventory_slots[slot_index].item
		if not item is BlockItem:
			return
		
		var block_indexer: BlockIndexer = item.get_block_index()
		
		# setting any inital attributes
		var attributes: Dictionary = {}
		for attribute: VoxelBlockyAttribute in block_indexer.get_attributes():
			if attribute is VoxelBlockyAttributeAxis:
				
				match abs(collision_normal):
					Vector3.FORWARD:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_Z
					Vector3.UP:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_Y
					Vector3.RIGHT:
						attributes["axis"] = VoxelBlockyAttributeAxis.AXIS_X
				
			elif attribute is VoxelBlockyAttributeDirection:
				
				match collision_normal:
					Vector3.FORWARD:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_Z
					Vector3.UP:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_Y
					Vector3.RIGHT:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_X
					Vector3.BACK:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_POSITIVE_Z
					Vector3.DOWN:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_Y
					Vector3.LEFT:
						attributes["axis"] = VoxelBlockyAttributeDirection.DIR_NEGATIVE_X
				
			elif attribute is VoxelBlockyAttributeRotation:
				printerr("No rotation handling")
		
		
		# get index
		var index: int
		
		match attributes.size():
			0:
				index = block_indexer.get_base_index()
			1:
				index = block_indexer.get_index_with_attribute(attributes.values()[0])
			_:
				index = block_indexer.get_index_with_attributes(attributes)
		
		
		# place and remove from inventory
		inventory.remove_amount_from_slot(slot_index, 1)
		voxel_terrain.add_voxel(voxel_position, index)

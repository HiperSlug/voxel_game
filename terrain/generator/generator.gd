extends VoxelGeneratorMultipassCB
class_name MyGenerator

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_amplitude: int = 10
@export var blocks_library: VoxelBlockyTypeLibrary = preload("res://data/voxel_blocks/blocks_library.tres")

# CHANGE TO USE BLOCKS

var log_index: int = blocks_library.get_model_index_single_attribute(&"log", VoxelBlockyAttributeAxis.AXIS_Y)
var dirt_index: int = blocks_library.get_model_index_default(&"dirt")
var grass_index: int = blocks_library.get_model_index_default(&"grass")
var air_index: int = blocks_library.get_model_index_default(&"air")

func _generate_pass(voxel_tool: VoxelToolMultipassGenerator, pass_index: int):
	
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	
	# these are the main positions, not editable
	var min_pos := voxel_tool.get_main_area_min() 
	var max_pos := voxel_tool.get_main_area_max()
	
	var size := max_pos - min_pos
	
	if pass_index == 0:
		
		# base terrain
		for z: int in range(min_pos.z, max_pos.z):
			for x: int in range(min_pos.x, max_pos.x):
				
				var terrain_height: int = get_height_at_position(x, z)
				
				for y: int in range(min_pos.y, max_pos.y):
					
					var position: Vector3i = Vector3i(x, y, z)
					
					if y < terrain_height:
						
						voxel_tool.set_voxel(position, dirt_index) 
						
					elif y == terrain_height:
						
						voxel_tool.set_voxel(position, grass_index)
						
					else:
						
						voxel_tool.set_voxel(position, air_index)
	
	elif pass_index == 1:
		
		# trees
		var rng := RandomNumberGenerator.new()
		rng.seed = get_seed_from_min_position(min_pos)
		
		# 4 tree attempts
		for i: int in range(4):
			
			var rand_x: int = rng.randi() % size.x
			var rand_z: int = rng.randi() % size.z
			var x: int = rand_x + min_pos.x
			var z: int = rand_z + min_pos.z
			
			var y: int = get_height_at_position(x, z) + 1
			if clampi(y, min_pos.y, max_pos.y) != y:
				continue
			
			var position: Vector3i = Vector3i(x, y, z)
			var structure: Structure = TreeGenerator.generate()
			var lower_corner_position := position - structure.offset
			
			voxel_tool.paste_masked(lower_corner_position, structure.voxels, 1 << VoxelBuffer.CHANNEL_TYPE, VoxelBuffer.CHANNEL_TYPE, 0)


func get_seed_from_min_position(pos: Vector3i) -> int:
	return (pos.x * 73856093) ^ (pos.y * 19349663) ^ (pos.z * 83492791)

func get_height_at_position(x: int, z: int) -> int:
	return int(floor(noise.get_noise_2d(x, z) * noise_amplitude))

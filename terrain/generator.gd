extends VoxelGeneratorMultipassCB
class_name MyGenerator

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_amplitude: int = 10
@export var tree_group: LookupGroup:
	set(value):
		tree_group = value
		var trees: Array[Resource] = tree_group.get_res_arr()
		for tree: Resource in trees:
			var array: Array = []
			array.resize(4)
			
			var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
			VoxelBlockSerializer.deserialize_from_byte_array(tree.data, voxel_buffer, true)
			array[0] = voxel_buffer
			
			for i in range(4):
				array[i] = voxel_buffer
				
				voxel_buffer = rotate_voxel_buffer_y_90(voxel_buffer)
			
			tree_to_buffer_dict[tree] = array
			
var tree_to_buffer_dict: Dictionary = {}

var blocks: LookupGroup = preload("res://data/group_block.tres")
#var dirt_index: int = Block.block_library.get_model_index_default(&"dirt")
#var grass_index: int = Block.block_library.get_model_index_default(&"grass")
#var air_index: int = Block.block_library.get_model_index_default(&"air")

# chat gpt function. I didnt want to write it myself.
func rotate_voxel_buffer_y_90(og_buffer: VoxelBuffer) -> VoxelBuffer:
	var size = Vector3i(
		og_buffer.get_size().x,
		og_buffer.get_size().y,
		og_buffer.get_size().z
	)
	
	var new_buffer = VoxelBuffer.new()
	new_buffer.create(size.z, size.y, size.x)

	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				# Get voxel value at current position
				var value = og_buffer.get_voxel(x, y, z, VoxelBuffer.CHANNEL_TYPE)
				
				# Rotated position (90° clockwise around Y axis)
				var new_x = size.z - 1 - z
				var new_y = y
				var new_z = x
				
				new_buffer.set_voxel(value, new_x, new_y, new_z, VoxelBuffer.CHANNEL_TYPE)
	
	return new_buffer


var rng := RandomNumberGenerator.new()
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
						
						voxel_tool.set_voxel(position, 0) 
						
					elif y == terrain_height:
						
						voxel_tool.set_voxel(position, 0) 
						
					else:
						
						voxel_tool.set_voxel(position, 0) 
	
	elif pass_index == 1:
		
		# trees
		rng.seed = get_seed_from_min_position(min_pos)
		
		# 4 tree attempts
		for i: int in range(4):
			
			# IN ORDER TO GET DETERMINISTIC PLACING I HAVE TO IMPLIEMENT A GLOBAL WAY OF KNOWING WHERE TREES ARE.=
			# THIS WOULD REPLACE THE CURRENT SEEDED RNG.
			var rand_x: int = rng.randi() % size.x
			var rand_z: int = rng.randi() % size.z
			var x: int = rand_x + min_pos.x
			var z: int = rand_z + min_pos.z
			
			var y: int = get_height_at_position(x, z) + 1
			if clampi(y, min_pos.y, max_pos.y) != y:
				continue
			
			var position: Vector3i = Vector3i(x, y, z) # global
			var tree: Resource = tree_group.get_res_rand(rng)
			var lower_corner_position: Vector3i = position - tree.offset
			
			var aabb: AABB = tree.overlap_aabb
			aabb.position += Vector3(lower_corner_position)
			
			var overlap: bool = get_aabb_overlap(aabb, voxel_tool)
			if overlap:
				continue
			
			var voxel_buffer: VoxelBuffer = tree_to_buffer_dict[tree][rng.randi() % 4]
			
			var channel := VoxelBuffer.CHANNEL_TYPE
			var mask := 1 << channel
			
			var array := PackedInt32Array([0, 13])
			array.resize((13 + 1) * 8)
			voxel_tool.paste_masked_writable_list(
				lower_corner_position, 
				voxel_buffer, 
				mask, 
				channel, 
				0,
				channel, 
				array)


func get_seed_from_min_position(pos: Vector3i) -> int:
	return (pos.x * 73856093) ^ (pos.y * 19349663) ^ (pos.z * 83492791)

func get_height_at_position(x: int, z: int) -> int:
	return int(floor(noise.get_noise_2d(x, z) * noise_amplitude))

func get_aabb_overlap(aabb: AABB, voxel_tool: VoxelToolMultipassGenerator) -> bool:
	for _x: int in range(aabb.position.x, aabb.end.x):
		for _y: int in range(aabb.position.y, aabb.end.y):
			for _z: int in range(aabb.position.z, aabb.end.z):
				var pos: Vector3i = Vector3i(_x, _y, _z)
				
				var voxel_index: int = voxel_tool.get_voxel(pos)
				if not voxel_index == 0:
					return true
	return false

extends VoxelGeneratorMultipassCB
class_name MyGenerator

@export var noise: FastNoiseLite = FastNoiseLite.new()
@export var noise_amplitude: int = 10
@export var plains_tree_group: LookupGroup:
	set(value):
		plains_tree_group = value
		var trees: Array[Resource] = plains_tree_group.get_res_arr()
		for tree: Resource in trees:
			var array: Array = []
			array.resize(4)
			
			var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
			VoxelBlockSerializer.deserialize_from_byte_array(tree.data, voxel_buffer, true)
			array[0] = voxel_buffer
			
			for i in range(4):
				array[i] = voxel_buffer
				
				voxel_buffer = rotate_voxel_buffer_y_90(voxel_buffer)
			
			plains_tree_to_buffer_dict[tree] = array
			
var plains_tree_to_buffer_dict: Dictionary = {}

@export var tundra_tree_group: LookupGroup:
	set(value):
		tundra_tree_group = value
		var trees: Array[Resource] = tundra_tree_group.get_res_arr()
		for tree: Resource in trees:
			var array: Array = []
			array.resize(4)
			
			var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
			VoxelBlockSerializer.deserialize_from_byte_array(tree.data, voxel_buffer, true)
			array[0] = voxel_buffer
			
			for i in range(4):
				array[i] = voxel_buffer
				
				voxel_buffer = rotate_voxel_buffer_y_90(voxel_buffer)
			
			tundra_tree_to_buffer_dict[tree] = array
			
var tundra_tree_to_buffer_dict: Dictionary = {}

var blocks: BlockLibrary = preload("res://data/blocks/block_library.tres")
var dirt_index: int = blocks.get_block_s(&"dirt").index
var grass_block_plains_index: int = blocks.get_block_s(&"grass_block").multi_blocks[0].index
var grass_block_tundra_index: int = blocks.get_block_s(&"grass_block").multi_blocks[1].index
var grass_plains_index: int = blocks.get_block_s(&"grass").multi_blocks[0].multi_blocks[3].index
var grass_tundra_index: int = blocks.get_block_s(&"grass").multi_blocks[1].multi_blocks[3].index
var flower_index: int = blocks.get_block_s(&"red_chocolate").multi_blocks[3].index

var writable_list: PackedInt32Array = PackedInt32Array([
	0, 
	blocks.get_block_s(&"leaves").multi_blocks[0].index, 
	blocks.get_block_s(&"leaves").multi_blocks[1].index, 
	grass_plains_index, 
	grass_tundra_index, 
	flower_index,
	])

const biome_noise := preload("res://terrain/biome_noise.tres")
enum BIOME {
	PLAINS,
	TUNDRA,
}
static func get_biome(position: Vector3i) -> BIOME:
	if biome_noise.get_noise_3d(position.x, position.y, position.z) < .5:
		return BIOME.PLAINS
	else:
		return BIOME.TUNDRA


var rng := RandomNumberGenerator.new()
func _generate_pass(voxel_tool: VoxelToolMultipassGenerator, pass_index: int):
	
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	
	# these are the main positions, not editable
	var min_pos := voxel_tool.get_main_area_min() 
	var max_pos := voxel_tool.get_main_area_max()
	
	var size := max_pos - min_pos
	
	var chunk_biome = null
	@warning_ignore("integer_division")
	var sample_points: Array[Vector3i] = [
		Vector3i(min_pos.x, min_pos.y, min_pos.z),
		Vector3i(max_pos.x, min_pos.y, min_pos.z),
		Vector3i(min_pos.x, max_pos.y, min_pos.z),
		Vector3i(min_pos.x, min_pos.y, max_pos.z),
		Vector3i(max_pos.x, max_pos.y, min_pos.z),
		Vector3i(min_pos.x, max_pos.y, max_pos.z),
		Vector3i(max_pos.x, min_pos.y, max_pos.z),
		Vector3i(max_pos.x, max_pos.y, max_pos.z),
	]
	for point: Vector3i in sample_points:
		if chunk_biome == null:
			chunk_biome = get_biome(point)
		elif chunk_biome != get_biome(point):
			chunk_biome = null
			break
	
	
	if pass_index == 0:
		
		# base terrain
		for z: int in range(min_pos.z, max_pos.z):
			for x: int in range(min_pos.x, max_pos.x):
				
				var terrain_height: int = get_height_at_position(x, z)
				
				for y: int in range(min_pos.y, max_pos.y):
					
					var position: Vector3i = Vector3i(x, y, z)
					
					var biome: BIOME
					if chunk_biome:
						biome = chunk_biome
					else:
						biome = get_biome(position)
					
					if y < terrain_height:
						
						voxel_tool.set_voxel(position, dirt_index) 
						
					elif y == terrain_height:
						
						match biome:
							BIOME.PLAINS:
								voxel_tool.set_voxel(position, grass_block_plains_index) 
							BIOME.TUNDRA:
								voxel_tool.set_voxel(position, grass_block_tundra_index) 
						
					else:
						
						voxel_tool.set_voxel(position, 0) 
	
	elif pass_index == 1:
		
		# trees
		rng.seed = get_seed_from_min_position(min_pos)
		
		for i: int in range(20):
			#break #
			var rand_x: int = rng.randi() % size.x
			var rand_z: int = rng.randi() % size.z
			var x: int = rand_x + min_pos.x
			var z: int = rand_z + min_pos.z
			
			var y: int = get_height_at_position(x, z) + 1
			if clampi(y, min_pos.y, max_pos.y) != y:
				continue
			
			var position: Vector3i = Vector3i(x, y, z) # global
			
			var biome: BIOME
			if chunk_biome:
				biome = chunk_biome
			else:
				biome = get_biome(position)
			
			match biome:
				BIOME.TUNDRA:
					voxel_tool.set_voxel(position, grass_tundra_index)
				BIOME.PLAINS:
					voxel_tool.set_voxel(position, grass_plains_index)
		
		for i: int in range(10):
			#break #
			var rand_x: int = rng.randi() % size.x
			var rand_z: int = rng.randi() % size.z
			var x: int = rand_x + min_pos.x
			var z: int = rand_z + min_pos.z
			
			var y: int = get_height_at_position(x, z) + 1
			if clampi(y, min_pos.y, max_pos.y) != y:
				continue
			
			var position: Vector3i = Vector3i(x, y, z) # global
			
			voxel_tool.set_voxel(position, flower_index)
		
		# 4 tree attempts
		
		
		for i: int in range(1):
			#break #
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
			
			var biome: BIOME
			if chunk_biome:
				biome = chunk_biome
			else:
				biome = get_biome(position)
			
			var tree: Resource
			match biome:
				BIOME.TUNDRA:
					tree = tundra_tree_group.get_res_rand(rng)
				BIOME.PLAINS:
					tree = plains_tree_group.get_res_rand(rng)
			
			var lower_corner_position: Vector3i = position - tree.offset
			
			var aabb: AABB = tree.overlap_aabb
			aabb.position += Vector3(lower_corner_position)
			
			var overlap: bool = get_aabb_overlap(aabb, voxel_tool)
			if overlap:
				continue
			
			var voxel_buffer: VoxelBuffer
			match biome:
				BIOME.TUNDRA:
					voxel_buffer = tundra_tree_to_buffer_dict[tree][rng.randi() % 4]
				BIOME.PLAINS:
					voxel_buffer = plains_tree_to_buffer_dict[tree][rng.randi() % 4]

			
			var channel := VoxelBuffer.CHANNEL_TYPE
			var mask := 1 << channel
			
			var max_val: int = 0
			for val: int in writable_list:
				max_val = max(max_val, val)
			writable_list.resize((max_val + 1) * 8)
			
			voxel_tool.paste_masked_writable_list(
				lower_corner_position, 
				voxel_buffer, 
				mask, 
				channel, 
				0,
				channel, 
				writable_list)


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
				if not voxel_index in writable_list:
					return true
	return false

# CHATGPT
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

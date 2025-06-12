extends Node
class_name CMDParser

@export var chat: ChatGUI
@export var structures: LookupGroup
@onready var voxel_tool: VoxelTool = get_tree().get_first_node_in_group("voxel_terrain").get_voxel_tool()
var saved_positions: Dictionary = {}

func parse_cmd(cmd: String) -> void:
	
	if cmd.begins_with("/"):
		cmd = cmd.erase(0)
	
	var arguments: PackedStringArray = cmd.split(" ", false)
	
	if arguments.size() <= 0:
		chat.push_message("no command")
	
	var command: String = arguments[0]
	
	match command:
		"save":
			save_structure(arguments)
		"aabb":
			preview_aabb(arguments)
		"pos":
			save_position(arguments)
		"load":
			load_structure(arguments)
		"get":
			get_variables(arguments)
		"item":
			get_item(arguments)
		_:
			chat.system_message("
				/save name key_1 key_2 -> saves a structure between two positions
				/load name key -> loads a structure at a position
				/aabb key_1 key_2 -> displays a box between the two positions
				/pos key -> saves current position as key 
				/get -> returns all positions and keys
				/item name amount -> gives the player the item of that name. Replace all spaces with \"_\"
				
				THIS IS THE UPDATED LIST.")




var item_group: LookupGroup = preload("res://data/group_item.tres")
func get_item(arguments: PackedStringArray) -> void:
	if arguments.size() != 3:
		chat.system_message("invalid arguments:
			/item name amount")
		return
	
	var parsed_name: String = arguments[1]
	parsed_name = parsed_name.capitalize()
	
	var item = item_group.get_resource_from_property(parsed_name)
	if item == null:
		chat.system_message("invalid name: {0}".format([parsed_name]))
		return
	
	if not arguments[2].is_valid_int():
		chat.system_message("invalid amount: {0}".format([arguments[2]]))
		return
	
	var amount: int = arguments[2].to_int()
	
	var inventory: Inventory = get_tree().get_first_node_in_group("inventory")
	inventory.add_items(item, amount)

func load_structure(arguments: PackedStringArray) -> void:
	if OS.has_feature("build"):
		chat.system_message("cmds interacing with the file system dont work in builds")
		return
	
	if arguments.size() < 3:
		chat.system_message("invalid arguments:
			/load name key index")
		return
	
	var file_name: String = arguments[1]
	var file_path: String = "res://data/structure/{0}".format([file_name])
	
	var structure_group = structures.get_resource_from_property(file_path)
	if structure_group == null:
		chat.system_message("invalid structure: {0}".format([file_name]))
	structure_group = structure_group as LookupGroup
	
	var structure: Structure
	if arguments.size() == 4 and arguments[3].is_valid_int():
		
		var index: int = arguments[3].to_int()
		if index > structure_group.resources.size():
			chat.system_message("index out of bounds")
			return
			
		structure = structure_group.resources[index]
	else:
		structure = structure_group.get_random(RandomNumberGenerator.new())
	
	var key: String = arguments[2]
	if not saved_positions.has(key):
		chat.system_message("invalid key: {0}".format([key]))
		return
	var load_position: Vector3i = saved_positions[key]
	
	var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
	VoxelBlockSerializer.deserialize_from_byte_array(structure.data, voxel_buffer, true)
	
	voxel_tool.paste(load_position - structure.offset, voxel_buffer, 1 << VoxelBuffer.CHANNEL_TYPE)
	chat.system_message("pasted")


@export var temporary_mesh_scene: PackedScene
func preview_aabb(arguments: PackedStringArray) -> void:
	
	if arguments.size() < 3:
		chat.system_message("invalid arguments:
			/aabb key key")
		return
	
	var key_1: String = arguments[1]
	var key_2: String = arguments[2]
	if not saved_positions.has(key_1):
		chat.system_message("invalid key: {0}".format([key_1]))
		return
	if not saved_positions.has(key_2):
		chat.system_message("invalid key: {0}".format([key_2]))
		return
	
	var position_1: Vector3i = saved_positions[key_1]
	var position_2: Vector3i = saved_positions[key_2]
	
	var aabb := AABB()
	aabb.position = Vector3(position_1)
	aabb.size = Vector3(position_2 - position_1)
	aabb = aabb.abs()
	aabb.size += Vector3.ONE
	
	# mesh
	var mesh := ArrayMesh.new()
	
	var arrays: Array = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices: PackedVector3Array = []
	for index: int in range(8):
		vertices.append(aabb.get_endpoint(index))
		#vertices.append(aabb.get_endpoint(index) - aabb.get_center())
	
	# chatgpt made this array for me.
	var indices: PackedInt32Array = PackedInt32Array([
	0, 1, 1, 3, 3, 2, 2, 0,
	4, 5, 5, 7, 7, 6, 6, 4,
	0, 4, 1, 5, 2, 6, 3, 7
	])
	
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	
	var mesh_instance: TemporaryMesh = temporary_mesh_scene.instantiate()
	mesh_instance.mesh = mesh
	
	
	#mesh_instance.transform.origin = aabb.get_center()
	var fx_node: Node = get_tree().get_first_node_in_group("fx")
	fx_node.add_child(mesh_instance)
	mesh_instance.start(20)



func save_position(arguments: PackedStringArray) -> void:
	
	if arguments.size() != 2:
		chat.system_message("invalid arguments:
			/pos key_name")
		return 
	
	var variable_name: String = arguments[1]
	
	var player_position: Vector3 = get_tree().get_first_node_in_group("player").global_position
	var voxel_position: Vector3i = Vector3i(player_position.floor())
	
	saved_positions[variable_name] = voxel_position
	chat.system_message("position: {0}".format([voxel_position]))


func get_variables(_arguments: PackedStringArray) -> void:
	for key: String in saved_positions:
		var message: String = "{0}: {1}".format([key, saved_positions[key]])
		chat.system_message(message)


func save_structure(arguments: PackedStringArray) -> void:
	if OS.has_feature("build"):
		chat.system_message("cmds interacing with the file system dont work in builds")
		return
	
	if arguments.size() != 4:
		chat.system_message("invalid arguments
		/str_save name saved_pos_1 saved_pos_2")
		return
	
	var file_name: String = arguments[1]
	if not file_name.is_valid_filename():
		return "invalid name: {0}".format([file_name])
	
	var key_1: String = arguments[2]
	var key_2: String = arguments[3]
	if not saved_positions.has(key_1):
		chat.system_message("invalid key: {0}".format([key_1]))
		return
	if not saved_positions.has(key_2):
		chat.system_message("invalid key: {0}".format([key_2]))
		return
	
	var position_1: Vector3 = Vector3(saved_positions[key_1])
	var position_2: Vector3 = Vector3(saved_positions[key_2])
	
	
	
	var folder_path: String = "res://data/structure/{0}".format([file_name])
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_absolute(folder_path)
		
		var lookup_group_name: String = "group_{0}".format([file_name])
		var lookup_group_path: String = "{0}/{1}.tres".format([folder_path, lookup_group_name])
		
		var lookup_group: LookupGroup = LookupGroup.new()
		lookup_group.includes.append("*.tres")
		lookup_group.excludes.append("{0}.tres".format([lookup_group_name]))
		lookup_group.base_folder = folder_path
		
		ResourceSaver.save(lookup_group, lookup_group_path)
	
	
	var file_index: int = 0
	var path: String = "{0}/{1}_{2}.tres".format([folder_path, file_name, file_index])
	while ResourceLoader.exists(path):
		file_index += 1
		path = "{0}/{1}_{2}.tres".format([folder_path, file_name, file_index])
	
	
	var aabb := AABB()
	aabb.position = position_1
	aabb.size = position_2 - position_1
	aabb = aabb.abs()
	aabb.size += Vector3.ONE
	
	var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
	var aabb_size: Vector3i = Vector3i(aabb.size)
	voxel_buffer.create(aabb_size.x, aabb_size.y, aabb_size.z)
	
	voxel_tool.copy(aabb.position, voxel_buffer, 1 << VoxelBuffer.CHANNEL_TYPE)
	
	var structure: Structure = Structure.new()
	var data := VoxelBlockSerializer.serialize_to_byte_array(voxel_buffer, true)
	structure.data = data
	structure.offset = Vector3i(int(floor(aabb.size.x / 2.0)), 0, int(floor(aabb.size.z / 2.0)))
	
	ResourceSaver.save(structure, path)
	
	structures.reload()
	structures.get_resource_from_property(folder_path).reload()
	
	chat.system_message("saved:
		size: {0}".format([aabb_size]))

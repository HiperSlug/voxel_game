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
		chat.push_message("empty command")
	
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
			chat.cmd_message("
				/save name key_1 key_2 -> saves a structure between two positions
				/load name key -> loads a structure at a position
				/aabb key_1 key_2 -> displays a box between the two positions
				/pos key -> saves current position as key 
				/get -> returns all positions and keys
				/item name amount -> gives the player the item of that name. Replace all spaces with \"_\"
				
				THIS IS THE UPDATED LIST.")



enum AXIS {
	X = 0,
	Y = 1,
	Z = 2,
}


signal cmd_response(response: String)
func receive_response(response: String) -> void:
	if response.begins_with("/"):
		response = response.erase(0)
	cmd_response.emit(response)

func get_response() -> String:
	chat.cmd_expects_response()
	return await cmd_response

func parse_position(argument: String):
	
	# if key in saved positions
	if saved_positions.has(argument):
		return saved_positions[argument]
	
	# otherwise its raw coordinates
	var component_arr: PackedStringArray = argument.split(",")
	if component_arr.size() != 3:
		return null
	
	var x = parse_pos_component(component_arr[AXIS.X], AXIS.X)
	var y = parse_pos_component(component_arr[AXIS.Y], AXIS.Y)
	var z = parse_pos_component(component_arr[AXIS.Z], AXIS.Z)
	if x == null or y == null or z == null:
		return null
	
	var position: Vector3i = Vector3i(x, y, z)
	return position

func parse_pos_component(pos_component: String, axis: AXIS):
	# relative position
	if pos_component.contains("~"):
		pos_component = pos_component.replace("~", "")
		
		if pos_component.is_empty():
			var player_position: Vector3i = get_player_voxel_position()
			var component: int
			match axis:
				AXIS.X:
					component = player_position.x
				AXIS.Y:
					component = player_position.y
				AXIS.Z:
					component = player_position.z
			return component
		
		if pos_component.is_valid_int():
			var relative_component: int = pos_component.to_int()
			var player_component: int
			var player_position: Vector3i = get_player_voxel_position()
			match axis:
				AXIS.X:
					player_component = player_position.x
				AXIS.Y:
					player_component = player_position.y
				AXIS.Z:
					player_component = player_position.z
			
			var net_component: int = player_component + relative_component
			return net_component
		return null
	
	else:
		if pos_component.is_valid_int():
			var absolute_component: int = pos_component.to_int()
			return absolute_component

@onready var player: Player = get_tree().get_first_node_in_group("player")
func get_player_voxel_position() -> Vector3i:
	var player_position: Vector3 = player.global_position
	var voxel_position: Vector3i = Vector3i(player_position.floor())
	return voxel_position

func create_aabb_mesh(corner_1: Vector3, corner_2: Vector3) -> TemporaryMesh:
	var aabb := get_aabb(corner_1, corner_2)
	
	# mesh
	var mesh := ArrayMesh.new()
	
	var arrays: Array = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices: PackedVector3Array = []
	for index: int in range(8):
		vertices.append(aabb.get_endpoint(index))
	
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
	
	var fx_node: Node = get_tree().get_first_node_in_group("fx")
	fx_node.add_child(mesh_instance)
	return mesh_instance

func get_yes_no(message: String):
	while true:
		chat.cmd_message(message)
		var response: String = await get_response()
		if response == "y":
			return true
		elif response == "n":
			return false
		elif response == "exit":
			return null
	
	return false

func get_box(message: String):
	while true:
		chat.cmd_message(message)
		
		var response = await get_response()
		
		if response == "exit":
			return null
		
		var response_args: PackedStringArray = response.split(" ")
		if response_args.size() != 2:
			chat.cmd_message("invalid positions")
			continue
		
		var pos_1 = parse_position(response_args[0])
		var pos_2 = parse_position(response_args[1])
		if pos_1 != null and pos_2 != null:
			
			var aabb: TemporaryMesh = create_aabb_mesh(pos_1, pos_2)
			
			var satisfactory = await get_yes_no("keep box? y/n")
			if satisfactory == null:
				aabb.queue_free()
				return null
			elif satisfactory:
				aabb.queue_free()
				return [pos_1, pos_2]
			else:
				aabb.queue_free()
				continue
			
			
		else:
			chat.cmd_message("invalid positions")
			continue

func get_aabb(pos_1: Vector3, pos_2: Vector3) -> AABB:
	var aabb := AABB()
	aabb.position = pos_1
	aabb.size = pos_2 - pos_1
	aabb = aabb.abs()
	aabb.size += Vector3.ONE
	return aabb

func get_point(message: String):
	while true:
		chat.cmd_message(message)
		var response = await get_response()
		
		if response == "exit":
			return null
		
		var pos = parse_position(response)
		if pos != null:
			
			var aabb: TemporaryMesh = create_aabb_mesh(pos, pos)
			
			var satisfactory = await get_yes_no("keep point? y/n")
			if satisfactory == null:
				aabb.queue_free()
				return null
			elif satisfactory:
				aabb.queue_free()
				return pos
			else:
				aabb.queue_free()
				continue
			
		else:
			chat.cmd_message("invalid position")
			continue

func get_index_from_list(message: String, options: Array):
	chat.cmd_message(message)
	for i: int in range(options.size()):
		chat.cmd_message("[{0}]: {1}".format([i, options[i]]), false)
	
	chat.cmd_message("choose an index")
	while true:
		var result: String = await get_response()
		if result == "exit":
			return null
		
		
		if not result.is_valid_int():
			chat.cmd_message("not an integer")
			continue
		
		var index: int = result.to_int()
		
		if index >= options.size() or index < 0:
			chat.cmd_message("index out of bounds")
			continue
		
		return index

var item_group: LookupGroup = preload("res://data/group_item.tres")
func get_item(arguments: PackedStringArray) -> void:
	if arguments.size() != 3:
		chat.cmd_message("invalid arguments:
			/item name amount")
		return
	
	var parsed_name: String = arguments[1]
	parsed_name = parsed_name.capitalize()
	
	var item = item_group.get_res_key(parsed_name)
	if item == null:
		chat.cmd_message("invalid name: {0}".format([parsed_name]))
		return
	
	if not arguments[2].is_valid_int():
		chat.cmd_message("invalid amount: {0}".format([arguments[2]]))
		return
	
	var amount: int = arguments[2].to_int()
	
	var inventory: Inventory = get_tree().get_first_node_in_group("inventory")
	inventory.add_items(item, amount)


func load_structure(arguments: PackedStringArray) -> void:
	
	if arguments.size() != 2:
		chat.cmd_message("invalid arguments:
			/load name")
		return
	
	
	var file_name: String = arguments[1]
	var file_path: String = "res://data/structure/{0}".format([file_name])
	
	var structure_group = structures.get_res_key(file_path)
	if structure_group == null:
		chat.cmd_message("invalid structure: {0}".format([file_name]))
	structure_group = structure_group as LookupGroup
	
	
	var structure_names: Array = structure_group.get_res_arr().map(func (res): return res.name)
	var index = await get_index_from_list("structures:", structure_names)
	if index == null:
		return
	
	var structure: Structure = structure_group.resources[index]
	
	
	var position = await get_point("where should the structure go?")
	if position == null:
		return
	position = position as Vector3i
	
	var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
	VoxelBlockSerializer.deserialize_from_byte_array(structure.data, voxel_buffer, true)
	
	voxel_tool.paste(position - structure.offset, voxel_buffer, 1 << VoxelBuffer.CHANNEL_TYPE)
	chat.cmd_message("loaded")


@export var temporary_mesh_scene: PackedScene
func preview_aabb(arguments: PackedStringArray) -> void:
	
	if arguments.size() < 3:
		chat.cmd_message("invalid arguments:
			/aabb key key")
		return
	
	var key_1: String = arguments[1]
	var key_2: String = arguments[2]
	if not saved_positions.has(key_1):
		chat.cmd_message("invalid key: {0}".format([key_1]))
		return
	if not saved_positions.has(key_2):
		chat.cmd_message("invalid key: {0}".format([key_2]))
		return
	
	var position_1: Vector3i = saved_positions[key_1]
	var position_2: Vector3i = saved_positions[key_2]
	
	var mesh_instance: TemporaryMesh = create_aabb_mesh(position_1, position_2)
	mesh_instance.start(20)




func save_position(arguments: PackedStringArray) -> void:
	
	if arguments.size() != 2:
		chat.cmd_message("invalid arguments:
			/pos key_name")
		return 
	
	var variable_name: String = arguments[1]
	
	var voxel_position: Vector3i = get_player_voxel_position()
	
	saved_positions[variable_name] = voxel_position
	chat.cmd_message("position: {0}".format([voxel_position]))


func get_variables(_arguments: PackedStringArray) -> void:
	for key: String in saved_positions:
		var message: String = "{0}: {1}".format([key, saved_positions[key]])
		chat.cmd_message(message)


func save_structure(arguments: PackedStringArray) -> void:
	
	var file_name: String = arguments[1]
	if not file_name.is_valid_filename():
		chat.cmd_message("invalid name: {0}".format([file_name]))
		return
	
	
	var structure_bounds = await get_box("input the bounds of the structure:")
	if structure_bounds == null:
		return
	structure_bounds = structure_bounds as Array[Vector3i]
	
	var structure_aabb := get_aabb(structure_bounds[0], structure_bounds[1])
	
	
	var wants_custom_aabb = await get_yes_no("independant overlap aabb? y/n")
	var overlap: Array = structure_bounds
	if wants_custom_aabb == null:
		return
	elif wants_custom_aabb:
		var returned_aabb_bounds = await get_box("input the bounds of the aabb:")
		if returned_aabb_bounds == null:
			return
		else:
			overlap = returned_aabb_bounds
	overlap = overlap as Array[Vector3i]
	
	var overlap_aabb := get_aabb(overlap[0], overlap[1])
	var local_overlap_aabb_position: Vector3i = overlap_aabb.position - structure_aabb.position
	var local_overlap_aabb: AABB = AABB(local_overlap_aabb_position, overlap_aabb.size)
	
	var grounded_x_point := int(floor(overlap_aabb.size.x / 2.0))
	var grounded_z_point := int(floor(overlap_aabb.size.z / 2.0))
	var grounded_mid_point := Vector3i(grounded_x_point, 0, grounded_z_point)
	
	var wants_custom_start_point = await get_yes_no("custom grounded middle position? y/n")
	if wants_custom_start_point == null:
		return
	elif wants_custom_start_point:
		var world_input_mid_point = await get_point("input point:")
		if world_input_mid_point == null:
			return
		else:
			var local_mid_point: Vector3i = world_input_mid_point - Vector3i(structure_aabb.position)
			grounded_mid_point = local_mid_point
	
	var folder_path: String
	if OS.has_feature("build"):
		folder_path = "user://data/structure/{0}".format([file_name])
	else:
		folder_path = "res://data/structure/{0}".format([file_name])
	
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
	
	
	
	var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
	var aabb_size: Vector3i = Vector3i(structure_aabb.size)
	voxel_buffer.create(aabb_size.x, aabb_size.y, aabb_size.z)
	
	voxel_tool.copy(structure_aabb.position, voxel_buffer, 1 << VoxelBuffer.CHANNEL_TYPE)
	voxel_buffer.compress_uniform_channels()
	
	var structure: Structure = Structure.new()
	var data := VoxelBlockSerializer.serialize_to_byte_array(voxel_buffer, true)
	structure.data = data
	structure.offset = grounded_mid_point
	structure.overlap_aabb = local_overlap_aabb
	structure.name = "{0}_{1}.tres".format([file_name, file_index])
	
	ResourceSaver.save(structure, path)
	
	structures.reload()
	structures.get_res_key(folder_path).reload()
	
	chat.cmd_message("saved to {0}".format([path]))

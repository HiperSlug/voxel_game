extends Control
class_name ChatGUI

@export var chat_input: LineEdit
@export var chat_container: VBoxContainer

func _ready() -> void:
	while true:
		await get_tree().create_timer(5).timeout
		save_position(PackedStringArray(["", "1"]))
		await get_tree().create_timer(3).timeout
		save_position(PackedStringArray(["", "2"]))
		preview_aabb(PackedStringArray(["", "1", "2"]))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("chat"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_chat_input_text_submitted(message: String) -> void:
	
	var label: Label = Label.new()
	label.text = message
	chat_container.add_child(label)
	
	if message.begins_with("/"):
		parse_cmd(message)
	
	chat_input.text = ""



func parse_cmd(cmd: String) -> void:
	
	cmd = cmd.erase(0)
	var argument_array: PackedStringArray = cmd.split(" ", false)
	if argument_array.size() <= 0:
		return
	
	
	match argument_array[0]:
		"save_structure":
			save_structure(argument_array)
		"preview_aabb":
			preview_aabb(argument_array)
		"save_position":
			save_position(argument_array)
		"load_structure":
			load_structure(argument_array)
		"get_variable":
			get_variable(argument_array)
	
@export var structures: LookupGroup

func load_structure(argument_array):
	if argument_array.size() != 2:
		printerr("not enough arguments to save structure")
		return
	
	if not argument_array[1].is_valid_filename():
		printerr("invalid filename")
		return
	
	var file_name: String = argument_array[1]
	
	

func preview_aabb(argument_array):
	print("preview")
	
	if argument_array.size() != 3:
		printerr("incorrect argument amount")
		return
	
	var variable_1: String = argument_array[1]
	var variable_2: String = argument_array[2]
	if not saved_positions.has(variable_1) or not saved_positions.has(variable_2):
		printerr("bad variable")
		return
	
	var position_1: Vector3i = round_away_from(saved_positions[variable_1], saved_positions[variable_2], true)
	var position_2: Vector3i = round_away_from(saved_positions[variable_2], saved_positions[variable_1], false)
	
	
	var aabb := AABB()
	aabb.position = Vector3(position_1)
	aabb.size = Vector3(position_2 - position_1)
	aabb = aabb.abs()
	
	var mesh_instance := MeshInstance3D.new()
	var mesh := ArrayMesh.new()
	
	var mesh_array: Array = []
	mesh_array.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices: PackedVector3Array = []
	for index: int in range(8):
		vertices.append(aabb.get_endpoint(index) - aabb.get_center())
	
	var indices: PackedInt32Array = PackedInt32Array([
	0, 1, 1, 3, 3, 2, 2, 0,  # Bottom
	4, 5, 5, 7, 7, 6, 6, 4,  # Top
	0, 4, 1, 5, 2, 6, 3, 7   # Sides
	])
	
	mesh_array[ArrayMesh.ARRAY_VERTEX] = vertices
	mesh_array[ArrayMesh.ARRAY_INDEX] = indices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, mesh_array)
	
	mesh_instance.mesh = mesh
	mesh_instance.transform.origin = aabb.get_center()
	get_tree().get_first_node_in_group("vfx").add_child(mesh_instance)


func round_away_from(vec3: Vector3, comparison: Vector3, inclusive: bool) -> Vector3i:
	var comps: Array[float] = [vec3.x, vec3.y, vec3.z]
	var comparison_comps: Array[float] = [comparison.x, comparison.y, comparison.z]
	for i: int in range(3):
		if inclusive:
			if comps[i] >= comparison_comps[i]:
				comps[i] = ceilf(comps[i])
			else:
				comps[i] = floorf(comps[i])
		else:
			if comps[i] > comparison_comps[i]:
				comps[i] = ceilf(comps[i])
			else:
				comps[i] = floorf(comps[i])
		
		
	
	return Vector3i(int(comps[0]), int(comps[1]), int(comps[2]))

var saved_positions: Dictionary = {}
func save_position(argument_array: PackedStringArray) -> void:
	
	print("save")
	
	if argument_array.size() != 2:
		printerr("not enough arguments")
		return
	
	var variable_name: String = argument_array[1]
	
	var player_position: Vector3 = get_tree().get_first_node_in_group("player").global_position
	
	saved_positions[variable_name] = player_position

func get_variable(argument_array: PackedStringArray) -> void:
	if argument_array.size() != 2:
		printerr("not enough arguments")
		return
	
	var variable_name: String = argument_array[1]
	print(saved_positions[variable_name])


@onready var voxel_tool: VoxelTool = get_tree().get_first_node_in_group("voxel_terrain").get_voxel_tool()
# ex
# /save_structure bill 1 1 1 2 2 2
func save_structure(argument_array: PackedStringArray) -> void:
	if argument_array.size() != 4:
		printerr("not enough arguments to save structure")
		return
	
	if not argument_array[1].is_valid_filename():
		printerr("invalid filename")
		return
	
	var file_name: String = argument_array[1]
	
	
	var variable_1: String = argument_array[1]
	var variable_2: String = argument_array[2]
	if not saved_positions.has(variable_1) or not saved_positions.has(variable_2):
		printerr("bad variable")
		return
	
	var position_1: Vector3i = round_away_from(saved_positions[variable_1], saved_positions[variable_2], true)
	var position_2: Vector3i = round_away_from(saved_positions[variable_2], saved_positions[variable_1], false)
	
	
	var aabb := AABB()
	aabb.position = Vector3(position_1)
	aabb.size = Vector3(position_2 - position_1)
	aabb = aabb.abs()
	var bottom_left_front_corner: Vector3i = Vector3i(aabb.position)
	var aabb_size: Vector3i = Vector3i(aabb.size)
	
	if aabb_size == Vector3i.ZERO:
		printerr("invalid size")
		return
	
	var voxel_buffer: VoxelBuffer = VoxelBuffer.new()
	voxel_buffer.create(aabb_size.x, aabb_size.y, aabb_size.z)
	
	voxel_tool.copy(bottom_left_front_corner, voxel_buffer, 1 << VoxelBuffer.CHANNEL_TYPE)
	
	var structure: Structure = Structure.new()
	structure.voxels = voxel_buffer
	
	
	var location: String
	if OS.has_feature("build"):
		location = "user"
	else:
		location = "res"
	
	
	
	var folder_path: String = "{0}://data/structure/{1}/".format([location, file_name])
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_absolute(folder_path)
		
		var random_group_name: String = "group_{0}".format([file_name])
		var random_group_path: String = "{0}{1}.tres".format([folder_path, random_group_name])
		
		var random_group: RandomGroup = RandomGroup.new()
		
		random_group.includes.append("*.tres")
		random_group.excludes.append("{0}.tres".format([random_group_name]))
		random_group.base_folder = folder_path.erase(folder_path.length() - 1)
		
		ResourceSaver.save(random_group, random_group_path)
	
	
	var file_index: int = 0
	var path: String = "{0}{1}_{2}.tres".format([folder_path, file_name, file_index])
	
	
	while ResourceLoader.exists(path):
		file_index += 1
		path = "{0}{1}_{2}.tres".format([folder_path, file_name, file_index])
	
	var error: Error = ResourceSaver.save(structure, path)
	if error != OK:
		printerr("Failed to save structure: ", error)

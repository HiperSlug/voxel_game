extends MeshInstance3D
class_name TemporaryMesh


func start(time: float) -> void:
	$Timer.start(time)

func _on_timer_timeout() -> void:
	queue_free()

const temporary_mesh_scene: PackedScene = preload("res://temporary_mesh/temporary_mesh.tscn")

static func create_aabb_mesh(corner_1: Vector3, corner_2: Vector3) -> TemporaryMesh:
	var aabb := get_aabb_from_corners(corner_1, corner_2)
	
	# mesh
	var _mesh := ArrayMesh.new()
	
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
	
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	var mesh_instance: TemporaryMesh = temporary_mesh_scene.instantiate()
	mesh_instance.mesh = _mesh
	
	return mesh_instance

static func get_aabb_from_corners(pos_1: Vector3, pos_2: Vector3) -> AABB:
	var aabb := AABB()
	aabb.position = pos_1
	aabb.size = pos_2 - pos_1
	aabb = aabb.abs()
	aabb.size += Vector3.ONE
	return aabb

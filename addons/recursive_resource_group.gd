extends ResourceGroup
class_name RecursiveGroup

@export var do_recursion: bool = true

func reload() -> void:
	paths = get_matching_paths(includes, excludes)

func get_matching_paths(includes: Array[String], excludes: Array[String]) -> Array[String]:
	var path_verifier := PathVerifier.new(base_folder, includes, excludes)
	var matching_paths: Array[String] = []
	
	if not DirAccess.dir_exists_absolute(base_folder):
		push_error("Failed to open directory: " + base_folder)
		return matching_paths
	
	walk_directory(base_folder, matching_paths, path_verifier)
	
	return matching_paths

func walk_directory(current_path: String, matching_paths: Array, path_verifier: PathVerifier) -> void:
	if not DirAccess.dir_exists_absolute(current_path):
		return
	
	var dir := DirAccess.open(current_path)
	if dir == null:
		printerr("invalid path")
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := current_path.path_join(file_name)
		if dir.current_is_dir() and do_recursion:
			walk_directory(full_path, matching_paths, path_verifier)
		else:
			if path_verifier.matches(full_path):
				matching_paths.append(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

extends RecursiveGroup
class_name LookupGroup


### EXTENSION TO RESOURCE GROUPS BUILT BY ME ###


@export var sort_property: StringName
var resource_dict: Dictionary = {}

func reload() -> void:
	super()
	update_resources()

func update_resources() -> void:
	load_all_into(resources)
	resources.sort()
	
	if sort_property == "":
		return
	
	for res: Resource in resources:
		
		var property = res.get(sort_property)
		if property == null:
			printerr("invalid property")
			continue
		
		resource_dict[property] = res

func get_res_key(value: Variant):
	if sort_property == "":
		printerr("no sort_property set")
		return 
	
	if resource_dict.size() == 0:
		update_resources()
		if resource_dict.size() == 0:
			printerr("no resources with property")
			return
	
	if not resource_dict.has(value):
		update_resources()
		if not resource_dict.has(value):
			printerr("invalid value")
			return
		
	return resource_dict[value]


@export var resources: Array[Resource] = []
func get_res_rand(rng: RandomNumberGenerator = RandomNumberGenerator.new()) -> Resource:
	if resources.size() == 0:
		load_all_into(resources)
		if resources.size() == 0:
			printerr("no resources in group")
	
	var seeded_index: int = rng.randi() % resources.size()
	return resources[seeded_index]

func get_res_ind(index: int):
	if index >= resources.size():
		printerr("index out of bounds")
		return null
	
	return resources[index]

func get_res_arr() -> Array[Resource]:
	if resources.size() == 0:
		update_resources()
	return resources

func res_key_exists(key) -> bool:
	if sort_property == "":
		printerr("no sort_property set")
		return false
	
	if resource_dict.size() == 0:
		update_resources()
		if resource_dict.size() == 0:
			printerr("no resources with property")
			return false
	
	if not resource_dict.has(key):
		update_resources()
		if not resource_dict.has(key):
			printerr("invalid value")
			return false
	
	return true

extends RecursiveGroup
class_name LookupGroup


### EXTENSION TO RESOURCE GROUPS BUILT BY ME


@export var sort_property: StringName

func set_sorting_property(property_name: StringName) -> void:
	if sort_property != null:
		printerr("sort_property reassignment.")
	sort_property = property_name
	update_dictionary()

var resource_dict: Dictionary = {}

func update_dictionary() -> void:
	for res: Resource in load_all():
		
		var property = res.get(sort_property)
		if property == null:
			printerr("invalid property")
			continue
		
		resource_dict[property] = res

func get_resource_from_property(value: Variant):
	if sort_property == null:
		printerr("no sort_property set")
		return 
	
	if resource_dict.size() == 0:
		update_dictionary()
		if resource_dict.size() == 0:
			printerr("no resources with property")
			return
	
	if not resource_dict.has(value):
		printerr("invalid value")
		return
		
	return resource_dict[value]

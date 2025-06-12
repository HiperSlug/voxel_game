extends RecursiveGroup
class_name RandomGroup

var resources: Array[Resource] = []
func get_random(rng: RandomNumberGenerator) -> Resource:
	if resources.size() == 0:
		load_all_into(resources)
		if resources.size() == 0:
			printerr("no resources in group")
	
	var seeded_index: int = rng.randi() % resources.size()
	return resources[seeded_index]

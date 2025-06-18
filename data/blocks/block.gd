@tool
extends Resource
class_name Block

@export var name: StringName = "":
	set(value):
		name = value
		set_name(name)




@export var support_type: SUPPORT:
	set(value):
		support_type = value
		for block: Block in multi_blocks:
			block.support_type = support_type
			block.notify_property_list_changed()
@export var can_support: bool = true:
	set(value):
		can_support = value
		for block: Block in multi_blocks:
			block.can_support = can_support
			block.notify_property_list_changed()

enum SUPPORT {
	NONE,
	BOTTOM,
	BOTTOM_OR_SIDES,
}

enum MODE {
	SINGLE,
	AXIS,
	HORIZONTAL_DIRECTION,
	BIOME,
	MULTI,
}
@export var mode: MODE:
	set(value):
		mode = value
		notify_property_list_changed()



# single
@export var index: int

# axis
@export var index_y: int
@export var index_z: int
@export var index_x: int

# horizontal_direction
@export var index_neg_z: int
@export var index_pos_z: int
@export var index_neg_x: int
@export var index_pos_x: int


# multi
@export var multi_blocks: Array[Block] = []

func _validate_property(property: Dictionary) -> void:
	match mode:
		MODE.SINGLE:
			allow_properties(["index"], property)
			
		MODE.AXIS:
			allow_properties(["index_z", "index_x", "index_y"], property)
			
		MODE.HORIZONTAL_DIRECTION:
			allow_properties(["index_pos_z", "index_neg_z", "index_pos_x", "index_neg_x"], property)
			
		MODE.BIOME:
			allow_properties(["multi_blocks"], property)
		
		MODE.MULTI:
			allow_properties(["multi_blocks"], property)
	

const screened_properties: Array[String] = [
	"index",
	"index_y",
	"index_z",
	"index_x",
	"index_pos_z",
	"index_neg_z",
	"index_pos_x",
	"index_neg_x",
	"multi_blocks",
]
func allow_properties(properties: Array[String], property: Dictionary) -> void:
	if property.name in properties:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif property.name in screened_properties:
		property.usage = PROPERTY_USAGE_NONE

func all_indices() -> Array[int]:
	match mode:
		MODE.SINGLE:
			return [index]
			
		MODE.AXIS:
			return [index_z, index_x, index_y]
			
		MODE.HORIZONTAL_DIRECTION:
			return [index_pos_x, index_pos_z, index_neg_z, index_neg_x]
			
		MODE.BIOME:
			var indices: Array[int] = []
			for block: Block in multi_blocks:
				indices.append_array(block.all_indices())
			return indices
		
		MODE.MULTI:
			var indices: Array[int] = []
			for block: Block in multi_blocks:
				indices.append_array(block.all_indices())
			return indices
		
		_:
			return []

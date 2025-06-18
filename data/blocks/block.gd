@tool
extends Resource
class_name Block

@export var name: StringName = "":
	set(value):
		name = value
		set_name(name)

@export var editor_group: StringName = ""
@export var texture: Texture = null

enum MODE {
	SINGLE,
	AXIS,
	HORIZONTAL_DIRECTION,
	STAGE,
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

# stage
@export var index_stage_3: int
@export var index_stage_2: int
@export var index_stage_1: int
@export var index_stage_0: int


func _validate_property(property: Dictionary) -> void:
	match mode:
		MODE.SINGLE:
			allow_properties(["index"], property)
			
		MODE.AXIS:
			allow_properties(["index_z", "index_x", "index_y"], property)
			
		MODE.HORIZONTAL_DIRECTION:
			allow_properties(["index_pos_z", "index_neg_z", "index_pos_x", "index_neg_x"], property)
			
		MODE.STAGE:
			allow_properties(["index_stage_3", "index_stage_2", "index_stage_1", "index_stage_0"], property)


const screened_properties: Array[String] = [
	"index",
	"index_y",
	"index_z",
	"index_x",
	"index_pos_z",
	"index_neg_z",
	"index_pos_x",
	"index_neg_x",
	"index_stage_3",
	"index_stage_2",
	"index_stage_1",
	"index_stage_0"
]
func allow_properties(properties: Array[String], property: Dictionary) -> void:
	if property.name in properties:
		property.usage = PROPERTY_USAGE_DEFAULT
	elif property.name in screened_properties:
		property.usage = PROPERTY_USAGE_NONE

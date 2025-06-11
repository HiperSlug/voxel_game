extends CharacterBody3D
class_name Item3D

@export var item: Item
@export var count: int
@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	sprite_3d.texture = item.single_texture

func _on_pickup_area_area_entered(area: Area3D) -> void:
	
	if area.has_method("pickup_item"):
		var left_over_items: bool = area.pickup_item(item, count)
		count = left_over_items
		if count == 0:
			queue_free()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

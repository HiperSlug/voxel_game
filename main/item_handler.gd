extends Node3D
class_name ItemHandler

var item_3d_scene: PackedScene = preload("res://item_3d/item_3d.tscn")

func add_items(item_position: Vector3, item: Item, count: int = 1) -> void:
	var item_3d: Item3D = item_3d_scene.instantiate()
	
	item_3d.item = item
	item_3d.count = count
	
	item_3d.position = item_position
	add_child(item_3d)

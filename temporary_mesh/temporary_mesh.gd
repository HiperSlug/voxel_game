extends MeshInstance3D
class_name TemporaryMesh


func start(time: float) -> void:
	$Timer.start(time)

func _on_timer_timeout() -> void:
	queue_free()

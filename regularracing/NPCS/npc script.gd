extends Sprite3D

var timer := 0.0

func _process(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "offset:y", 200, 0.2)
	tween.tween_property(self, "offset:y", 0, 0.2)
	
	var random := randf_range(3.0, 10.0)
	timer = random

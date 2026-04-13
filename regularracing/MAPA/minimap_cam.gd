extends Camera3D

var player:Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	global_position = Vector3(
		player.global_position.x,
		50.0,
		player.global_position.z,
	)
	rotation.y = player.rotation.y

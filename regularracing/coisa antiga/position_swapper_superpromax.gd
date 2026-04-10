extends Area3D

@export var object1: Node3D
@export var object2: Node3D
@export var use_global_position = false
@export var swap_duration = 0.5

var object1_original_pos: Vector3
var object2_original_pos: Vector3
var is_swapped = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	if object1:
		if use_global_position:
			object1_original_pos = object1.global_position
		else:
			object1_original_pos = object1.position
		print("Object1 original pos: ", object1_original_pos)
	else:
		print("ERRO: Object1 não definido!")
	
	if object2:
		if use_global_position:
			object2_original_pos = object2.global_position
		else:
			object2_original_pos = object2.position
		print("Object2 original pos: ", object2_original_pos)
	else:
		print("ERRO: Object2 não definido!")

func _on_body_entered(body):
	print("Algo tocou a área: ", body.name)
	if body.name == "Ball":
		print("É a Ball! Trocando posições...")
		swap_positions()

func swap_positions():
	if not object1 or not object2:
		print("ERRO: Objetos não encontrados!")
		return

	var pos1: Vector3
	var pos2: Vector3

	if use_global_position:
		pos1 = object1.global_position
		pos2 = object2.global_position
	else:
		pos1 = object1.position
		pos2 = object2.position

	# troca real
	animate_swap(object1, pos2)
	animate_swap(object2, pos1)

func animate_swap(obj: Node3D, target_pos: Vector3):
	print("Movendo ", obj.name, " para ", target_pos)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if use_global_position:
		tween.tween_property(obj, "global_position", target_pos, swap_duration)
	else:
		tween.tween_property(obj, "position", target_pos, swap_duration)

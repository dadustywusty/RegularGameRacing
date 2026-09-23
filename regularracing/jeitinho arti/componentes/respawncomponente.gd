extends Area3D
class_name RespawnComponente

signal checkpoint_passado(id: int)

@onready var estatica = preload("uid://b5tj4m701bprn")
@onready var noise = preload("uid://buixv2j72y5ot")

@export var corpo : CharacterBody3D
var checkpoint_atual : Area3D
var respawn : Node3D

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("checkpoint"):
		checkpoint_atual = area
		checkpoint_passado.emit(area.get_index())
		for node in checkpoint_atual.get_children():
			if node.is_in_group("ponto respawn"):
				respawn = node
	
	if area.is_in_group("plano morte"):
		animacao_respawn()
		corpo.global_transform = respawn.global_transform
		corpo.velocity = Vector3.ZERO

func animacao_respawn() -> void:
	var new = estatica.instantiate()
	var som = AudioStreamPlayer.new()
	
	new.modulate.a = 1.00
	som.stream = noise
	
	get_tree().root.add_child(new)
	get_tree().root.add_child(som)
	
	som.finished.connect(som.queue_free)
	som.play()
	
	var tween = get_tree().create_tween()
	tween.tween_property(new, "modulate:a", 0.0, 0.5)
	tween.tween_callback(new.queue_free)

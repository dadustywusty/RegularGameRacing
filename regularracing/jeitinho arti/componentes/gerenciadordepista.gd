extends Node
class_name GerenciadorDePista

var modulos := []
var grupos := []
var spawns := []
var index := 0
var ultimo_modulo : PackedScene = null

func _ready() -> void:
	grupos = get_children()
	for grupo in grupos:
		desativar(grupo)
		for area in grupo.get_children():
			area.body_entered.connect(on_body_entered)
		ativar(grupos[0])
	
	spawns = get_node("../modulos").get_children()
	
	modulos = get_parent().modulos

func on_body_entered(_body: CharacterBody3D):
	desativar(grupos[index])
	spawns[index].get_child(0).queue_free()
	
	var novo = modulos.pick_random()
	var novissimo = novo.instantiate()
	spawns[index].add_child(novissimo)
	novissimo.global_position = spawns[index].global_position
	
	index = (index + 1) % grupos.size()
	ativar(grupos[index])

func ativar(node) -> void:
	for child in node.get_children():
		child.set_deferred("monitoring", true)

func desativar(node) -> void:
	for child in node.get_children():
		child.set_deferred("monitoring", false)

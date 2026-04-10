extends Node3D

@export var respawn_time = 5.0

enum ItemType {
	BOOST,
	TRIPLE_BOOST,
	SHIELD,
	BOMB,
	LIGHTNING,
	STAR
}

var items = [
	ItemType.BOOST,
	ItemType.TRIPLE_BOOST,
	ItemType.SHIELD,
	ItemType.BOMB,
	ItemType.LIGHTNING,
	ItemType.STAR
]

var is_active = true
var sprite
var mesh_instances = []
var collision_shape
var break_sound
var particles
var respawn_timer
var area
var animation_player

func _ready():
	print("=== Inicializando Item Box ===")
	print("Procurando nós na árvore...")
	
	sprite = find_child("Sprite3D", true, false)
	print("Sprite encontrado: ", sprite != null)
	
	find_all_mesh_instances(self)
	print("Total de MeshInstances encontrados: ", mesh_instances.size())
	
	animation_player = find_child("AnimationPlayer", true, false)
	print("AnimationPlayer encontrado: ", animation_player != null)
	
	if animation_player:
		randomize_animation_start()
	
	area = find_child("Area3D", true, false)
	print("Area3D encontrado: ", area != null)
	
	if area:
		collision_shape = area.get_node_or_null("CollisionShape3D")
		print("CollisionShape encontrado: ", collision_shape != null)
	
	break_sound = find_child("BreakingBad", true, false)
	print("BreakSound encontrado: ", break_sound != null)
	
	particles = find_child("GPUParticles3D", true, false)
	print("Particles encontrado: ", particles != null)
	
	respawn_timer = find_child("respawn", true, false)
	print("RespawnTimer encontrado: ", respawn_timer != null)
	
	if particles:
		particles.emitting = false
		particles.one_shot = true
		particles.lifetime = 2.0
		particles.explosiveness = 1.0
		print("Partículas configuradas: Lifetime=", particles.lifetime)
	
	if respawn_timer:
		respawn_timer.wait_time = respawn_time
		respawn_timer.timeout.connect(_on_respawn_timer_timeout)
	
	if area:
		area.body_entered.connect(_on_area_3d_body_entered)
		print("Sinal conectado com sucesso!")
	else:
		print("ERRO: Area3D não encontrado!")
		print("Verifique se existe um nó Area3D na cena")

func find_all_mesh_instances(node):
	if node is MeshInstance3D:
		mesh_instances.append(node)
		print("MeshInstance encontrado: ", node.name)
	
	for child in node.get_children():
		find_all_mesh_instances(child)

func _on_area_3d_body_entered(body):
	print("=== Algo tocou o item box! ===")
	print("Nome do body: ", body.name)
	print("Is active: ", is_active)
	
	if not is_active:
		print("Item box não está ativo")
		return
	
	if body.name == "Ball":
		print("É a Ball! Quebrando...")
		break_box(body)
	else:
		print("Não é a Ball")

func break_box(body):
	print("=== Quebrando item box! ===")
	is_active = false
	
	if break_sound:
		break_sound.pitch_scale = randf_range(0.8, 1.2)
		break_sound.play()
		print("Som tocando com pitch: ", break_sound.pitch_scale)
	
	if particles:
		print("Ativando partículas...")
		particles.restart()
		particles.emitting = true
		print("Partículas ativadas!")
	else:
		print("Partículas não encontradas!")
	
	if sprite:
		sprite.visible = false
		print("Sprite escondido")
	
	for mesh in mesh_instances:
		mesh.visible = false
		print("MeshInstance escondido: ", mesh.name)
	
	if collision_shape:
		collision_shape.disabled = true
		print("Colisão desativada")
	
	var random_item = items[randi() % items.size()]
	give_item_to_player(body, random_item)
	
	if respawn_timer:
		respawn_timer.start()
		print("Timer de respawn iniciado")

func give_item_to_player(body, item: ItemType):
	var player_script = body.get_parent()
	
	if player_script and player_script.has_method("receive_item"):
		player_script.receive_item(item)
	else:
		print("Player recebeu item: ", ItemType.keys()[item])

func _on_respawn_timer_timeout():
	if sprite:
		sprite.visible = true
	
	for mesh in mesh_instances:
		mesh.visible = true
	
	if collision_shape:
		collision_shape.disabled = false
	
	if animation_player:
		randomize_animation_start()
	
	is_active = true

func randomize_animation_start():
	if animation_player and animation_player.has_animation("Animação"):
		var anim_length = animation_player.get_animation("Animação").length
		var random_position = randf() * anim_length
		animation_player.play("Animação")
		animation_player.seek(random_position)

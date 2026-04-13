extends Node
class_name GerenciadorDePista

var modulos := []
var icones := {}
var grupos := []
var spawns := []
var index := 0

# Qual PackedScene está instanciada em cada spawn agora
var modulo_atual_por_spawn := []

func _ready() -> void:
	modulos = get_parent().modulos
	icones = get_parent().icones

	grupos = get_children()
	spawns = get_node("../modulos").get_children()

	modulo_atual_por_spawn.resize(spawns.size())
	modulo_atual_por_spawn.fill(null)

	# Começa tudo desativado, ativa só o primeiro grupo
	for grupo in grupos:
		_desativar_grupo(grupo)

	_preparar_grupo(index)
	_ativar_grupo(grupos[index])

func _preparar_grupo(idx: int) -> void:
	var grupo = grupos[idx]
	var areas = grupo.get_children()  # cada Area3D = uma opção

	# Copia módulos e remove o que já está no spawn desse índice
	var opcoes: Array = modulos.duplicate()
	if modulo_atual_por_spawn[idx] != null:
		opcoes.erase(modulo_atual_por_spawn[idx])
	opcoes.shuffle()

	# Distribui uma opção por área
	for i in areas.size():
		var area: Area3D = areas[i]

		# Limpa conexões antigas pra não acumular
		if area.body_entered.is_connected(_on_escolha):
			area.body_entered.disconnect(_on_escolha)

		if i < opcoes.size():
			var modulo_da_area: PackedScene = opcoes[i]
			area.set_meta("modulo_escolhido", modulo_da_area)
			area.set_meta("spawn_index", idx)
			area.body_entered.connect(_on_escolha.bind(area))

			# Seta textura no Sprite3D da área
			var sprite = area.get_node_or_null("Sprite3D")
			if sprite and icones.has(modulo_da_area):
				sprite.texture = icones[modulo_da_area]
				sprite.visible = true
		else:
			# Mais áreas do que opções — esconde
			var sprite = area.get_node_or_null("Sprite3D")
			if sprite:
				sprite.visible = false

func _on_escolha(body: Node3D, area: Area3D) -> void:
	if not body is CharacterBody3D:
		return

	var idx: int = area.get_meta("spawn_index")
	var modulo_escolhido: PackedScene = area.get_meta("modulo_escolhido")

	# Desativa grupo imediatamente pra não triggar duas vezes
	_desativar_grupo(grupos[idx])
	_limpar_icones(grupos[idx])

	# Troca o módulo no spawn
	var spawn = spawns[idx]
	if spawn.get_child_count() > 0:
		spawn.get_child(0).queue_free()

	var novo = modulo_escolhido.instantiate()
	spawn.add_child(novo)
	novo.global_position = spawn.global_position

	modulo_atual_por_spawn[idx] = modulo_escolhido

	# Avança e prepara o próximo grupo
	index = (index + 1) % grupos.size()
	_preparar_grupo(index)
	_ativar_grupo(grupos[index])

func _limpar_icones(grupo: Node) -> void:
	for area in grupo.get_children():
		var sprite = area.get_node_or_null("Sprite3D")
		if sprite:
			sprite.visible = false
			sprite.texture = null

func _ativar_grupo(grupo: Node) -> void:
	for area in grupo.get_children():
		area.set_deferred("monitoring", true)

func _desativar_grupo(grupo: Node) -> void:
	for area in grupo.get_children():
		area.set_deferred("monitoring", false)

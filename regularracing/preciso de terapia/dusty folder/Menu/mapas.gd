extends Node2D

func _ready() -> void:
	Transicao.rect.scale = Vector2.ONE  # garante que está fechado
	Transicao.rect.visible = true
	Transicao._abrir()

func _on_mapa_de_teste_pressed() -> void:
	Transicao.transicionar("res://teste/mapa de teste.tscn")
func _on_rainbow_road_pressed() -> void:
	Transicao.transicionar("res://teste/rainbow road.tscn")
func _on_toad_harbor_pressed() -> void:
	Transicao.transicionar("res://teste/toad harbor.tscn")
func _on_yoshi_ciruit_pressed() -> void:
	Transicao.transicionar("res://teste/yoshi circuit.tscn")
func _on_sabor_pressed() -> void:
	Transicao.transicionar("res://teste/sabor_baby_park.tscn")
func _on_voltar_pressed() -> void:
	Transicao.transicionar("res://dusty folder/Menu/main_menu.tscn")

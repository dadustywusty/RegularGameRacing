extends Node2D


func _on_mapa_de_teste_pressed() -> void:
	get_tree().change_scene_to_file("res://teste/mapa de teste.tscn")

func _on_rainbow_road_pressed() -> void:
	get_tree().change_scene_to_file("res://teste/rainbow road.tscn")

func _on_toad_harbor_pressed() -> void:
	get_tree().change_scene_to_file("res://teste/toad harbor.tscn")

func _on_yoshi_ciruit_pressed() -> void:
	get_tree().change_scene_to_file("res://teste/yoshi circuit.tscn")

func _on_sabor_pressed() -> void:
	get_tree().change_scene_to_file("res://teste/sabor_baby_park.tscn")

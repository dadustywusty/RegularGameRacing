extends Node3D

const MUSICA_TESTE := preload("res://dusty folder/MUSGA/08 - In The End.mp3")

func _ready() -> void:
	Musga.tocar_musica(MUSICA_TESTE, "mapa_teste")
	

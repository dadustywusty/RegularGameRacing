extends Control

@onready var posiçao_componente: PosiçaoComponente = %PosiçaoComponente
@onready var label: Label = $VBoxContainer/Label
@export var minimap_rect:TextureRect

func _ready() -> void:
	var minimap_viewport:SubViewport = get_tree().current_scene.get_node("MiniMapViewport")
	if minimap_rect:
		minimap_rect.texture = minimap_viewport.get_texture()

func _process(_delta: float) -> void:
	var tempo = posiçao_componente.tempo_atual
	label.text = posiçao_componente.converter_tempo_pra_string(tempo)

extends Control

@export var minimap_rect:TextureRect

func _ready() -> void:
	var minimap_viewport:SubViewport = get_tree().current_scene.get_node("MiniMapViewport")
	if minimap_rect:
		minimap_rect.texture = minimap_viewport.get_texture()

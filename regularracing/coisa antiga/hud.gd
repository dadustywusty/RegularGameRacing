extends Control

@onready var item_box = get_node_or_null("ItemBox")
@onready var item_icon = get_node_or_null("ItemBox/ItemIcon")
@onready var position_label = get_node_or_null("PositionInfo/PositionLabel")
@onready var lap_label = get_node_or_null("PositionInfo/LapLabel")
@onready var drift_bar = get_node_or_null("DriftBar/ProgressBar")
@onready var minimap = get_node_or_null("Minimap/MinimapContainer")
@onready var static_overlay = get_node_or_null("StaticOverlay")

@export var total_laps = 3

var current_position = 1
var current_lap = 1
var drift_progress = 0.0

func _ready():
	update_position(1)
	update_lap(1)
	update_drift_bar(0.0)
	hide_item()

func update_position(pos: int):
	if not position_label:
		return
	current_position = pos
	position_label.text = str(pos) + get_position_suffix(pos)

func get_position_suffix(pos: int) -> String:
	match pos:
		1: return "st"
		2: return "nd"
		3: return "rd"
		_: return "th"

func update_lap(lap: int):
	if not lap_label:
		return
	current_lap = lap
	lap_label.text = str(lap) + "/" + str(total_laps)

func update_drift_bar(progress: float):
	if not drift_bar:
		return
	drift_progress = clamp(progress, 0.0, 1.0)
	drift_bar.value = drift_progress * 100
	
	if drift_progress >= 1.0:
		drift_bar.modulate = Color(0, 1, 0)
	elif drift_progress >= 0.5:
		drift_bar.modulate = Color(1, 1, 0)
	else:
		drift_bar.modulate = Color(1, 1, 1)

func show_item(item_name: String):
	if not item_icon:
		return
	item_icon.visible = true
	match item_name:
		"BOOST":
			item_icon.text = "🚀"
		"TRIPLE_BOOST":
			item_icon.text = "🚀x3"
		"SHIELD":
			item_icon.text = "🛡️"
		"BOMB":
			item_icon.text = "💣"
		"LIGHTNING":
			item_icon.text = "⚡"
		"STAR":
			item_icon.text = "⭐"
		_:
			item_icon.text = "?"

func hide_item():
	if not item_icon:
		return
	item_icon.visible = false

func show_static_effect():
	if not static_overlay:
		return
	static_overlay.visible = true

func hide_static_effect():
	if not static_overlay:
		return
	static_overlay.visible = false

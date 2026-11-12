extends Node

# seed: 0 = случайный
var world_seed: int = 0

# 0.0 / 0.25 / 0.5 / 0.75 — как на кнопках
var height_level: float = 0.5
var humidity_level: float = 0.5
var rivers_level: float = 0.5      # заглушка
var population_level: float = 0.5  # заглушка

func set_seed_from_text(text: String) -> void:
	text = text.strip_edges()
	if text.is_empty():
		world_seed = 0
		return
	if text.is_valid_int():
		world_seed = text.to_int()
	else:
		# любой текст → стабильный seed
		world_seed = text.hash()

func reset_to_defaults() -> void:
	world_seed = 0
	height_level = 0.5
	humidity_level = 0.5
	rivers_level = 0.5
	population_level = 0.5

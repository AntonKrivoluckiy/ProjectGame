class_name BlueprintCell
extends RefCounted

var offset: Vector2i = Vector2i.ZERO
var part_id: String = "floor"
var layer: int = 0 # Этажность, пока всегда 0

func _init(p_offset: Vector2i = Vector2i.ZERO, p_part_id: String = "floor", p_layer: int = 0) -> void:
	offset = p_offset
	part_id = p_part_id
	layer = p_layer

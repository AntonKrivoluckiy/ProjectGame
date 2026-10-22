class_name BuildingType
extends RefCounted

var id: String = ""
var name: String = ""
var allowed_parts: Array[String] = []

func _init(p_id: String = "", p_name: String = "", p_parts: Array[String] = []) -> void:
	id = p_id
	name = p_name
	allowed_parts = p_parts
	
func allows(part_id: String) -> bool:
	return part_id in allowed_parts

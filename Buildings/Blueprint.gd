class_name Blueprint
extends RefCounted

var id: String = ""
var name: String = ""
var building_type_id: String = "dwelling"
var cells: Array[BlueprintCell] = []

func _init(p_id: String = "", p_name: String = "", p_type: String = "dwelling") -> void:
	id = p_id
	name = p_name
	building_type_id = p_type
	
func add_cell(offset: Vector2i, part_id: String, layer: int = 0) -> void:
	cells.append(BlueprintCell.new(offset, part_id, layer))
	
func get_world_cells(origin: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in cells:
		result.append(origin + cell.offset)
	return result

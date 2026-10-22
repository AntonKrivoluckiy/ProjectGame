extends  Node

var buildings: Dictionary = {}
var next_id: int = 0

var blueprints: Dictionary = {}
var building_types: Dictionary = {}

signal building_created(building_id: int)
signal building_remowed(building_id: int)

func _ready() -> void:
	_register_types()
	_register_default_blueprints()
	
func _register_types() -> void:
	building_types["dwelling"] = BuildingType.new(
		"dwelling",
		"housing",
		["floor", "wall", "door", "window", "oven"]
	)
	building_types["workshop"] = BuildingType.new(
		"workshop",
		"workshop",
		["floor", "wall", "door", "window", "workbench"]
	)

func _register_default_blueprints() -> void:
	# house 2x2: пол + стены по краю + дверь
	var hut = Blueprint.new("hut_2x2", "hut", "dwellind")
	# floor
	hut.add_cell(Vector2i(1, 1), "floor")
	hut.add_cell(Vector2i(1, 2), "floor")
	hut.add_cell(Vector2i(2, 1), "floor")
	hut.add_cell(Vector2i(2, 2), "floor")
	# walls
	hut.add_cell(Vector2i(0, 0), "wall")
	hut.add_cell(Vector2i(0, 1), "wall")
	hut.add_cell(Vector2i(0, 2), "wall")
	hut.add_cell(Vector2i(0, 3), "wall")
	hut.add_cell(Vector2i(1, 0), "wall")
	hut.add_cell(Vector2i(1, 3), "wall")
	hut.add_cell(Vector2i(2, 0), "wall")
	hut.add_cell(Vector2i(2, 3), "wall")
	hut.add_cell(Vector2i(3, 0), "wall")
	hut.add_cell(Vector2i(3, 1), "wall")
	hut.add_cell(Vector2i(3, 2), "door")
	hut.add_cell(Vector2i(3, 3), "wall")
	
	blueprints[hut.id] = hut
	
func GetBlueprint(blueprint_id: String) -> Blueprint:
	return blueprints.get(blueprint_id, null)

func CreateBuilding(blueprint_id: String, origin: Vector2i) -> int:
	var bp = GetBlueprint(blueprint_id)
	if bp == null:
		push_warning("Blueprint not found: " + blueprint_id)
		return -1
	
	var b = Building.new()
	b.id = next_id
	b.blueprint_id = blueprint_id
	b.origin = origin
	
	buildings[next_id] = b
	building_created.emit(next_id)
	next_id += 1
	return b.id

func GetBuilding(id: int) -> Building:
	return buildings.get(id, null)

func RemoveBuilding(id: int) -> void:
	if buildings.has(id):
		buildings.erase(id)
		building_remowed.emit(id)

func GetBuildingAtTile(tile: Vector2i) -> Building:
	for b in buildings.values():
		var bp: Blueprint = GetBlueprint(b.blueprint_id)
		if bp == null:
			continue
		for cell in bp.cells:
			if b.origin + cell.offset == tile:
				return b
	return null

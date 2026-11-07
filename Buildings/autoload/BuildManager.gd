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
	# заглушка house 2x2: пол + стены по краю + дверь
	var hut = Blueprint.new("hut", "hut", "dwelling")
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

var selected_blueprint_id = "" # "" - ничего не выбрано

signal selection_changed(blueprint_id: String)

func SelectBlueprint(blueprint_id: String) -> void:
	# повторный клик - снять выбор
	if selected_blueprint_id == blueprint_id:
		selected_blueprint_id = ""
	else:
		selected_blueprint_id = blueprint_id
	selection_changed.emit(selected_blueprint_id)
	
func ClearSelection() -> void:
	selected_blueprint_id = ""
	selection_changed.emit(selected_blueprint_id)
	
func IsSelected(blueprint_id: String) -> bool:
	return selected_blueprint_id == blueprint_id

func CanPlaceBuilding(blueprint_id: String, origin: Vector2i) -> bool:
	var bp = GetBlueprint(blueprint_id)
	if bp == null:
		return false
	
	for cell in bp.cells:
		var tile: Vector2i = origin + cell.offset
		var map_cell = TileDatabase.GetCell(tile)
		
		# нет клетки / за краем карты
		if map_cell == null:
			return false
		# биом не позволяет строить (вода, горы…)
		if not map_cell.can_have_builds:
			return false
		# уже что-то стоит
		if map_cell.have_builds:
			return false
		# на всякий случай — другой building
		if GetBuildingAtTile(tile) != null:
			return false
	
	return true
	
func TryPlaceBuilding(blueprint_id: String, origin: Vector2i) -> int:
	if blueprint_id == "":
		return -1
	
	# 1) хватает ли дерева
	const COST := 20
	if ResourcesManager.wood < COST:
		return -1   # или сообщение в консоль
	
	# 2) можно ли по клеткам
	if not CanPlaceBuilding(blueprint_id, origin):
		return -1
	
	# 3) создаём
	var id = CreateBuilding(blueprint_id, origin)
	if id < 0:
		return -1
	
	# 4) списываем только после успеха
	ResourcesManager.wood -= COST
	_mark_cells_occupied(blueprint_id, origin, true)
	return id

func _mark_cells_occupied(blueprint_id: String, origin: Vector2i, occupied: bool) -> void:
	var bp = GetBlueprint(blueprint_id)
	if bp == null:
		return
	for cell in bp.cells:
		var map_cell = TileDatabase.GetCell(origin + cell.offset)
		if map_cell == null:
			continue
		
		if occupied:
			if not map_cell.have_builds:
				map_cell.base_walk = map_cell.walk
				map_cell.base_walk_speed = map_cell.walk_speed
			map_cell.have_builds = true
			match cell.part_id:
				"wall":
					map_cell.walk = false
					map_cell.walk_speed = 0.0
				"door":
					map_cell.walk = true
					# walk_speed можно не трогать
				"floor":
					map_cell.walk = true
					map_cell.walk_speed = 1.0
		else:
			map_cell.have_builds = false
			map_cell.walk = map_cell.base_walk
			map_cell.walk_speed = map_cell.base_walk_speed

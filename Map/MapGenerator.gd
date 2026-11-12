extends Node2D

# --- размер карты ---
var MapWidth: int = 1024
var MapHeight: int = 1024
var TileSize: int = 16

# --- форма острова ---
var island_radius: float = 0.97   # меньше = меньше остров
var edge_width: float = 0.14     # ширина «мягкого» берега
var peak_strength: float = 0.42  # сила центральной горы
var peak_radius: float = 0.22    # радиус конуса горы (доля карты)
var peak_offset_max: float = 0.08 # гора не ровно в центре (доля карты)

# --- частоты шумов ---
var height_frequency: float = 0.0028
var moisture_frequency: float = 0.0035
var temperature_frequency: float = 0.0030

# --- пороги высоты (0…1) ---
var H_DEEPWATER: float = 0.22
var H_WATER: float = 0.30
var H_SANDWATER: float = 0.36
var H_BEACH: float = 0.40
var H_LAND_MAX: float = 0.68   # до этого — равнина/лес
var H_HILLS: float = 0.78
var H_MOUNTAIN: float = 0.88
# выше H_MOUNTAIN → Snowmountain

# --- пороги влажности на равнине ---
var M_FIELD: float = 0.35
var M_SMALFOREST: float = 0.55
var M_FOREST: float = 0.75
# выше → Bigforest

# --- холод ---
var T_COLD: float = 0.38

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

var tile_data: Dictionary = {}
var world_seed: int = 0  # 0 = случайный при каждой генерации

func _ready() -> void:
	GenerateRegionMap()

func GenerateRegionMap() -> void:
	tile_data.clear()
	tilemap.clear()
	
	# --- настройки из меню ---
	world_seed = MapGenSettings.world_seed
	var height_bias: float = (MapGenSettings.height_level - 0.5) * 0.35
	# 0% → -0.175, 50% → 0, 75% → +0.0875
	var moisture_bias: float = (MapGenSettings.humidity_level - 0.5) * 0.4
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if world_seed == 0:
		world_seed = rng.randi()
	
	var noise_h := _make_noise(world_seed, height_frequency)
	var noise_m := _make_noise(world_seed + 1, moisture_frequency)
	var noise_t := _make_noise(world_seed + 2, temperature_frequency)
	
	# гора чуть смещена от центра
	var peak_ox: float = (rng.randf() * 2.0 - 1.0) * peak_offset_max
	var peak_oy: float = (rng.randf() * 2.0 - 1.0) * peak_offset_max
	
	var cx: float = MapWidth * 0.5
	var cy: float = MapHeight * 0.5
	
	for x in range(MapWidth):
		for y in range(MapHeight):
			var tile_pos := Vector2i(x, y)
			
			# --- маска острова (0 на краю, 1 в центре) ---
			var dx: float = (x - cx) / cx
			var dy: float = (y - cy) / cy
			var dist: float = sqrt(dx * dx + dy * dy)
			var island: float = 1.0 - _smoothstep(island_radius - edge_width, island_radius, dist)
			
			# --- шумы 0…1 ---
			var h_noise: float = (noise_h.get_noise_2d(x, y) + 1.0) * 0.5
			var moisture: float = (noise_m.get_noise_2d(x, y) + 1.0) * 0.5
			var temperature: float = (noise_t.get_noise_2d(x, y) + 1.0) * 0.5
			
			# высота: шум * маска острова
			var height: float = h_noise * island
			
			# центральная гора / «вулкан»
			var pdx: float = dx - peak_ox
			var pdy: float = dy - peak_oy
			var pdist: float = sqrt(pdx * pdx + pdy * pdy)
			if pdist < peak_radius and island > 0.05:
				var t: float = 1.0 - (pdist / peak_radius)
				height = minf(height + t * t * peak_strength * island, 1.0)
			
			var cell_type: int = _pick_biome(height, moisture, temperature)
			var atlas: Vector2i = _atlas_for_type(cell_type)
			
			tilemap.set_cell(tile_pos, 0, atlas)
			tile_data[tile_pos] = TileDatabase.CreateCellData(cell_type)
	
	TileDatabase.SetMapData(tile_data, MapWidth, MapHeight)
	camera.update_bounds(MapWidth, MapHeight, TileSize)
	print("Map seed=", world_seed,
			" height=", MapGenSettings.height_level,
			" humidity=", MapGenSettings.humidity_level)

func _make_noise(seed_value: int, frequency: float) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	n.seed = seed_value
	n.frequency = frequency
	n.fractal_type = FastNoiseLite.FRACTAL_FBM
	n.fractal_octaves = 4
	n.fractal_gain = 0.5
	n.fractal_lacunarity = 2.0
	return n

func _smoothstep(edge0: float, edge1: float, x: float) -> float:
	if edge1 <= edge0:
		return 0.0 if x < edge0 else 1.0
	var t: float = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

func _pick_biome(height: float, moisture: float, temperature: float) -> int:
	# вода и берег
	if height < H_DEEPWATER:
		return TileDatabase.TileType.Deepwater
	if height < H_WATER:
		return TileDatabase.TileType.Water
	if height < H_SANDWATER:
		return TileDatabase.TileType.Sandwater
	if height < H_BEACH:
		return TileDatabase.TileType.Beach
	
	# равнины / леса / «холодные равнины»
	if height < H_LAND_MAX:
		# холодно и не слишком влажно → холодная равнина (пока тот же Field)
		if temperature < T_COLD and moisture < 0.55:
			return TileDatabase.TileType.Field
		if moisture < M_FIELD:
			return TileDatabase.TileType.Field
		if moisture < M_SMALFOREST:
			return TileDatabase.TileType.Smalforest
		if moisture < M_FOREST:
			return TileDatabase.TileType.Forest
		return TileDatabase.TileType.Bigforest
	
	# возвышенности
	if height < H_HILLS:
		return TileDatabase.TileType.Hills
	if height < H_MOUNTAIN:
		return TileDatabase.TileType.Mountain
	return TileDatabase.TileType.Snowmountain

func _atlas_for_type(cell_type: int) -> Vector2i:
	match cell_type:
		TileDatabase.TileType.Deepwater:
			return Vector2i(10, 0)
		TileDatabase.TileType.Water:
			return Vector2i(9, 0)
		TileDatabase.TileType.Sandwater:
			return Vector2i(8, 0)
		TileDatabase.TileType.Beach:
			return Vector2i(7, 0)
		TileDatabase.TileType.Field:
			return Vector2i(6, 0)
		TileDatabase.TileType.Smalforest:
			return Vector2i(5, 0)
		TileDatabase.TileType.Forest:
			return Vector2i(4, 0)
		TileDatabase.TileType.Bigforest:
			return Vector2i(3, 0)
		TileDatabase.TileType.Hills:
			return Vector2i(2, 0)
		TileDatabase.TileType.Mountain:
			return Vector2i(1, 0)
		TileDatabase.TileType.Snowmountain:
			return Vector2i(0, 0)
		_:
			return Vector2i(6, 0)

var region_info_mode = false
var citizen_info_mode = false

func _is_pointer_over_blocking_ui() -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	if hovered == null:
		return false
	# клики по консоли для info-режимов разрешаем «сквозь» логику карты
	# блокируем только меню построек и т.п.
	if hovered is LineEdit:
		return true  # печатаем в консоль — карту не трогаем
	var build_menu = get_tree().root.find_child("BuildMenuUI", true, false)
	if build_menu and build_menu.is_ancestor_of(hovered):
		return true
	return false

func _input(event: InputEvent):
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	
	var console = get_tree().root.find_child("ConsoleUI", true, false)
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tilemap.local_to_map(mouse_pos)
	
	# Bulldoze
	if BuildManager.bulldoze_mode:
		if console and console.visible:
			pass
		elif _is_pointer_over_blocking_ui():
			return
		else:
			BuildManager.TryDemolishAt(tile_pos)  # или RemoveBuilding через GetBuildingAtTile
			return
	
	# Building
	if BuildManager.selected_blueprint_id != "":
		if console and console.visible:
			pass  # не строим, но не return — ниже может быть info
		elif _is_pointer_over_blocking_ui():
			return
		else:
			BuildManager.TryPlaceBuilding(BuildManager.selected_blueprint_id, tile_pos)
			return
	
	# Console
	if console and not console.visible:
		return
	
	#Region info
	if region_info_mode:
		# Проверяем, что координаты в пределах карты
		if tile_pos.x >= 0 and tile_pos.x < MapHeight and tile_pos.y >= 0 and tile_pos.y < MapWidth:
			var region_info = tile_data[tile_pos]
			
			Console.add_message(
"
==========REGION INFO==========
Position: {0}:
	__________
	Biom type: {1}
		Can walk: {2}
		- Walk speed: {3}
		Can swim: {4}
		- Swim speed: {5}
		Fertility: {6}
		Can have builds: {7}
		- Have build: {8}
	__________
==========REGION INFO=========="
.format([tile_pos, region_info.name, region_info.walk, region_info.walk_speed, region_info.swim, region_info.swim_speed, 
region_info.fertility, region_info.can_have_builds, region_info.have_builds]))
		
	#Citizen info
	if citizen_info_mode:
		var citizen = PopManager.find_citizen_at_tile(tile_pos)
		if citizen:
			Console.add_message(
"
==========CITIZEN INFO==========
Citizen id {0}:
Citizen Gender: {1}
	Citizen Name: {2}
Position: {3}
Health: {4}
Hunger: {5}
==========CITIZEN INFO=========="
.format([citizen.id, citizen.gender, citizen.name, citizen.position, citizen.health, citizen.hunger]))

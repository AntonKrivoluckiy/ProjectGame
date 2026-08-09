extends Node2D

var MapWidth = 1024
var MapHeight = 1024
var NoiseScale = 0.005
var TileSize = 16

var DeepwaterThreshold = -0.2
var WaterThreshold = -0.3
var SandwaterThreshold = -0.4
var BeachThreshold = -0.5
var FieldThreshold = -0.6
var SmalforestThreshold = -0.65
var ForestThreshold = -0.7
var BigforestThreshold = -0.75
var HillsThreshold = -0.8
var MountainThreshold = -0.85
var SnowmountainThreshold = -0.9

var region_info_mode = false

enum TileType{
	Deepwater,
	Water,
	Sandwater,
	Beach,
	Field,
	Smalforest,
	Forest,
	Bigforest,
	Hills,
	Mountain,
	Snowmountain
}

func GetTileType(type: int) -> CellData:
	var data = CellData.new()
	data.tile_type = type
	
	match type:
		TileType.Deepwater:
			data.walk = false
			data.walk_speed = 0.0
			data.fertility = 0.0
			data.swim = true
			data.swim_speed = 0.3
			data.can_have_builds = false
		TileType.Water:
			data.walk = false
			data.walk_speed = 0.0
			data.fertility = 0.0
			data.swim = true
			data.swim_speed = 0.5
			data.can_have_builds = false
		TileType.Sandwater:
			data.walk = false
			data.walk_speed = 0.0
			data.fertility = 0.0
			data.swim = true
			data.swim_speed = 0.6
			data.can_have_builds = false
		TileType.Beach:
			data.walk = true
			data.walk_speed = 0.4
			data.fertility = 0.3
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = false
		TileType.Field:
			data.walk = true
			data.walk_speed = 0.9
			data.fertility = 0.5
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = true
		TileType.Smalforest:
			data.walk = true
			data.walk_speed = 0.8
			data.fertility = 0.6
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = true
		TileType.Forest:
			data.walk = true
			data.walk_speed = 0.7
			data.fertility = 0.7
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = true
		TileType.Bigforest:
			data.walk = true
			data.walk_speed = 0.6
			data.fertility = 0.8
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = true
		TileType.Hills:
			data.walk = true
			data.walk_speed = 0.4
			data.fertility = 0.4
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = false
		TileType.Mountain:
			data.walk = true
			data.walk_speed = 0.2
			data.fertility = 0.0
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = false
		TileType.Snowmountain:
			data.walk = false
			data.walk_speed = 0.0
			data.fertility = 0.0
			data.swim = false
			data.swim_speed = 0.0
			data.can_have_builds = false
	return data

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

var tile_data = {}

func GenerateRegionMap():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	
	var rng = RandomNumberGenerator.new()
	noise.seed = rng.randi()

	noise.frequency = NoiseScale
	
	for x in range(MapWidth):
		for y in range(MapHeight):
			var noise_value = noise.get_noise_2d(x, y)
			
			var tile_pos = Vector2i(x, y)
			var cell_type: int
			
			cell_type = TileType.Snowmountain
			var atlas_cords = Vector2i(0, 0)
			
			if noise_value > DeepwaterThreshold:
				cell_type = TileType.Deepwater
				atlas_cords = Vector2i(10, 0)
			elif noise_value > WaterThreshold:
				cell_type = TileType.Water
				atlas_cords = Vector2i(9, 0)
			elif noise_value > SandwaterThreshold:
				cell_type = TileType.Sandwater
				atlas_cords = Vector2i(8, 0)
			elif noise_value > BeachThreshold:
				cell_type = TileType.Beach
				atlas_cords = Vector2i(7, 0)
			elif noise_value > FieldThreshold:
				cell_type = TileType.Field
				atlas_cords = Vector2i(6, 0)
			elif noise_value > SmalforestThreshold:
				cell_type = TileType.Smalforest
				atlas_cords = Vector2i(5, 0)
			elif noise_value > ForestThreshold:
				cell_type = TileType.Forest
				atlas_cords = Vector2i(4, 0)
			elif noise_value > BigforestThreshold:
				cell_type = TileType.Bigforest
				atlas_cords = Vector2i(3, 0)
			elif noise_value > HillsThreshold:
				cell_type = TileType.Hills
				atlas_cords = Vector2i(2, 0)
			elif noise_value > MountainThreshold:
				cell_type = TileType.Mountain
				atlas_cords = Vector2i(1, 0)
				
			tilemap.set_cell(tile_pos, 0, atlas_cords)
			tile_data[tile_pos] = GetTileType(cell_type)
	
	camera.update_bounds(MapWidth, MapHeight, 16)

func _ready() -> void:
	GenerateRegionMap()

func _input(event: InputEvent):
	# Получаем позицию мыши в мировых координатах
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tilemap.local_to_map(mouse_pos)

	## Проверяем, что это клик левой кнопкой
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Переводим в координаты тайла
		var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
		
		## Проверяем, не открыта ли консоль (чтобы не мешать вводу)
		var console = get_tree().root.find_child("ConsoleUI", true, false)
		
		if console and not console.visible:
			return
		
		if region_info_mode:
			# Проверяем, что координаты в пределах карты
			if tile_pos.x >= 0 and tile_pos.x < MapHeight and tile_pos.y >= 0 and tile_pos.y < MapWidth:
				var region_info = tile_data[tile_pos]
				
				Console.add_message(
"
position: ({0}):
	__________
	biom type: {1}
		walk: {2}
		walk speed: {3}
		swim: {4}
		swim speed: {5}
		fertility: {6}
		can have builds: {7}
	__________
==========
"
.format([atlas_coords, 'process', region_info.walk, region_info.walk_speed, region_info.swim, region_info.swim_speed, 
region_info.fertility, region_info.can_have_builds]))

func enable_region_info():
	region_info_mode = true
	Console.add_message("Режим отладки карты ВКЛЮЧЕН.")

func disable_region_info():
	region_info_mode = false
	Console.add_message("Режим отладки карты ВЫКЛЮЧЕН.")
	

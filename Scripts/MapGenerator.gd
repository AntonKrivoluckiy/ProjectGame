extends Node2D

var MapWidth = 1024
var MapHeight = 1024
var NoiseScale = 0.004
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
			
			cell_type = TileDatabase.TileType.Snowmountain
			var atlas_cords = Vector2i(0, 0)
			
			if noise_value > DeepwaterThreshold:
				cell_type = TileDatabase.TileType.Deepwater
				atlas_cords = Vector2i(10, 0)
			elif noise_value > WaterThreshold:
				cell_type = TileDatabase.TileType.Water
				atlas_cords = Vector2i(9, 0)
			elif noise_value > SandwaterThreshold:
				cell_type = TileDatabase.TileType.Sandwater
				atlas_cords = Vector2i(8, 0)
			elif noise_value > BeachThreshold:
				cell_type = TileDatabase.TileType.Beach
				atlas_cords = Vector2i(7, 0)
			elif noise_value > FieldThreshold:
				cell_type = TileDatabase.TileType.Field
				atlas_cords = Vector2i(6, 0)
			elif noise_value > SmalforestThreshold:
				cell_type = TileDatabase.TileType.Smalforest
				atlas_cords = Vector2i(5, 0)
			elif noise_value > ForestThreshold:
				cell_type = TileDatabase.TileType.Forest
				atlas_cords = Vector2i(4, 0)
			elif noise_value > BigforestThreshold:
				cell_type = TileDatabase.TileType.Bigforest
				atlas_cords = Vector2i(3, 0)
			elif noise_value > HillsThreshold:
				cell_type = TileDatabase.TileType.Hills
				atlas_cords = Vector2i(2, 0)
			elif noise_value > MountainThreshold:
				cell_type = TileDatabase.TileType.Mountain
				atlas_cords = Vector2i(1, 0)
				
			tilemap.set_cell(tile_pos, 0, atlas_cords)
			var cell_data = TileDatabase.CreateCellData(cell_type)
			tile_data[tile_pos] = cell_data
	
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
.format([tile_pos, region_info.name, region_info.walk, region_info.walk_speed, region_info.swim, region_info.swim_speed, 
region_info.fertility, region_info.can_have_builds]))

var region_info_mode = false

func region_info():
	region_info_mode = not region_info_mode
	if region_info_mode:
		Console.add_message("Режим отладки карты ВКЛЮЧЕН.")
	else:
		Console.add_message("Режим отладки карты ВЫКЛЮЧЕН.")
	

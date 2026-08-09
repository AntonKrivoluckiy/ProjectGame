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
var SnowThreshold = -0.9

var region_info_mode = false

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D

func GenerateRegionMap():
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	
	var rng = RandomNumberGenerator.new()
	var seed = rng.randi()
	
	noise.seed = seed
	noise.frequency = NoiseScale
	
	#var cities_placed = 0
	
	for x in range(MapWidth):
		for y in range(MapHeight):
			var noise_value = noise.get_noise_2d(x, y)
			
			var atlas_cords = Vector2i(0, 0)
			var tile_pos = Vector2i(x, y)
			
			if noise_value > DeepwaterThreshold:
				atlas_cords = Vector2i(10, 0)
			elif noise_value > WaterThreshold:
				atlas_cords = Vector2i(9, 0)
			elif noise_value > SandwaterThreshold:
				atlas_cords = Vector2i(8, 0)
			elif noise_value > BeachThreshold:
				atlas_cords = Vector2i(7, 0)
			elif noise_value > FieldThreshold:
				atlas_cords = Vector2i(6, 0)
			elif noise_value > SmalforestThreshold:
				atlas_cords = Vector2i(5, 0)
			elif noise_value > ForestThreshold:
				atlas_cords = Vector2i(4, 0)
			elif noise_value > BigforestThreshold:
				atlas_cords = Vector2i(3, 0)
			elif noise_value > HillsThreshold:
				atlas_cords = Vector2i(2, 0)
			elif noise_value > MountainThreshold:
				atlas_cords = Vector2i(1, 0)
				
			tilemap.set_cell(tile_pos, 0, atlas_cords)
	
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
				var region_info = get_biome_name(atlas_coords).split(";")
				
				Console.add_message("Биом: {0}:
	 	- Позиция: ({1}, {2})
	 	- Город: {3}".format([region_info[0], tile_pos.x, tile_pos.y, region_info[1]]))
		

func get_biome_name(atlas_coords: Vector2i) -> String:
	match atlas_coords:
		Vector2i(10, 0):
			return "Глубоководье;False"
		Vector2i(9, 0):
			return "Вода;False"
		Vector2i(8, 0):
			return "Мелководье;False"
		Vector2i(7, 0):
			return "Пляж;False"
		Vector2i(6, 0):
			return "Поле;False"
		Vector2i(5, 0):
			return "Мелкий лес;False"
		Vector2i(4, 0):
			return "Лес;False"
		Vector2i(3, 1):
			return "Густой лес;False"
		Vector2i(2, 1):
			return "Холм;False"
		Vector2i(1, 1):
			return "Гора;False"
		Vector2i(0, 0):
			return "Снежная вершина;False"
		_:
			return "Неизвестно;Неизвестно"
		
func enable_region_info():
	region_info_mode = true
	Console.add_message("Режим отладки карты ВКЛЮЧЕН.")

func disable_region_info():
	region_info_mode = false
	Console.add_message("Режим отладки карты ВЫКЛЮЧЕН.")
	

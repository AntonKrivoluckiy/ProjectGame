extends Panel

@onready var Seed: LineEdit = $SeedLine

@onready var Height0: Button = $Height0
@onready var Height25: Button = $Height25
@onready var Height50: Button = $Height50
@onready var Height75: Button = $Height75

@onready var Humidity0: Button = $Humidity0
@onready var Humidity25: Button = $Humidity25
@onready var Humidity50: Button = $Humidity50
@onready var Humidity75: Button = $Humidity75

@onready var Rives0: Button = $Rives0
@onready var Rives25: Button = $Rives25
@onready var Rives50: Button = $Rives50
@onready var Rives75: Button = $Rives75

@onready var Population0: Button = $Population0
@onready var Population25: Button = $Population25
@onready var Population50: Button = $Population50
@onready var Population75: Button = $Population75

@onready var Start: Button = $StartButton
@onready var Back: Button = $BackButton

var _height_buttons: Array[Button] = []
var _humidity_buttons: Array[Button] = []
var _rivers_buttons: Array[Button] = []
var _population_buttons: Array[Button] = []

func _ready() -> void:
	_height_buttons = [Height0, Height25, Height50, Height75]
	_humidity_buttons = [Humidity0, Humidity25, Humidity50, Humidity75]
	_rivers_buttons = [Rives0, Rives25, Rives50, Rives75]
	_population_buttons = [Population0, Population25, Population50, Population75]
	
	_connect_level_buttons(_height_buttons, _on_height)
	_connect_level_buttons(_humidity_buttons, _on_humidity)
	_connect_level_buttons(_rivers_buttons, _on_rivers)
	_connect_level_buttons(_population_buttons, _on_population)
	
	Start.pressed.connect(_on_start)
	Back.pressed.connect(_on_back)
	
	# подсветка текущих значений (дефолт 50%)
	_highlight(_height_buttons, 2)
	_highlight(_humidity_buttons, 2)
	_highlight(_rivers_buttons, 2)
	_highlight(_population_buttons, 2)

func _connect_level_buttons(buttons: Array[Button], handler: Callable) -> void:
	for i in buttons.size():
		buttons[i].pressed.connect(handler.bind(i))

func _level_from_index(index: int) -> float:
	# 0 → 0.0, 1 → 0.25, 2 → 0.5, 3 → 0.75
	return index * 0.25

func _on_height(index: int) -> void:
	MapGenSettings.height_level = _level_from_index(index)
	_highlight(_height_buttons, index)

func _on_humidity(index: int) -> void:
	MapGenSettings.humidity_level = _level_from_index(index)
	_highlight(_humidity_buttons, index)

func _on_rivers(index: int) -> void:
	MapGenSettings.rivers_level = _level_from_index(index)
	_highlight(_rivers_buttons, index)
	# пока только сохраняем, генерация не использует

func _on_population(index: int) -> void:
	MapGenSettings.population_level = _level_from_index(index)
	_highlight(_population_buttons, index)
	# заглушка

func _highlight(buttons: Array[Button], active: int) -> void:
	for i in buttons.size():
		buttons[i].modulate = Color(0.0, 0.672, 0.139, 1.0) if i == active else Color.WHITE

func _on_start() -> void:
	MapGenSettings.set_seed_from_text(Seed.text)
	get_tree().change_scene_to_file("res://scenes/Main-Game.tscn")

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

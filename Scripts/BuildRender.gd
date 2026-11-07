extends Node2D

const PART_ATLAS := {
	"wall": Vector2i(0, 0),
	"door": Vector2i(1, 0),
	"floor": Vector2i(2, 0),
}

@onready var buildings_layer: TileMapLayer = $"BuildingsLayer"
# путь подстрой под то, куда повесишь ноду

func _ready() -> void:
	BuildManager.building_created.connect(_on_building_created)
	BuildManager.building_remowed.connect(_on_building_removed)  # как у тебя в сигнале
	# если уже есть здания при загрузке:
	for id in BuildManager.buildings:
		_draw_building(id)

func _on_building_created(building_id: int) -> void:
	_draw_building(building_id)

func _on_building_removed(building_id: int) -> void:
	_clear_building(building_id)

func _draw_building(building_id: int) -> void:
	var b = BuildManager.GetBuilding(building_id)
	if b == null:
		return
	var bp = BuildManager.GetBlueprint(b.blueprint_id)
	if bp == null:
		return
	
	for cell in bp.cells:
		var atlas: Vector2i = PART_ATLAS.get(cell.part_id, Vector2i(-1, -1))
		if atlas.x < 0:
			continue
		var tile: Vector2i = b.origin + cell.offset
		# source_id = 0, если в TileSet один atlas source
		buildings_layer.set_cell(tile, 0, atlas)

func _clear_building(building_id: int) -> void:
	var b = BuildManager.GetBuilding(building_id)
	# Внимание: если RemoveBuilding уже erase'нул, нужен другой подход —
	# либо чистить клетки ДО erase, либо хранить snapshot клеток
	pass

extends Node2D

enum TileType{
	Deepwater,
	Water,
	Sandwater,
	Beach,
	Field,
	FieldTown,
	Smalforest,
	SmalforestTown,
	Forest,
	ForestTown,
	Bigforest,
	Hills,
	Mountain,
	Snowmountain
}

var PropType: Dictionary = {}

func _ready() -> void:
	PropInit()

func RegType(type_id: int, props: Dictionary):
	PropType[type_id] = props

func PropInit():
	RegType(TileType.Deepwater, {
		"name": "Deep Water",
		"walk": false,
		"walk_speed": 0.0,
		"swim": true,
		"swim_speed": 0.4,
		"fertility": 0.0,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Water, {
		"name": "Water",
		"walk": false,
		"walk_speed": 0.0,
		"swim": true,
		"swim_speed": 0.5,
		"fertility": 0.0,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Sandwater, {
		"name": "Sand Water",
		"walk": false,
		"walk_speed": 0.0,
		"swim": true,
		"swim_speed": 0.6,
		"fertility": 0.0,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Beach, {
		"name": "Beach",
		"walk": true,
		"walk_speed": 0.4,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.4,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Field, {
		"name": "Field",
		"walk": true,
		"walk_speed": 0.9,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.5,
		"can_have_builds": true,
		"have_builds": false 
	})
	RegType(TileType.Smalforest, {
		"name": "Smal Forest",
		"walk": true,
		"walk_speed": 0.8,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.6,
		"can_have_builds": true,
		"have_builds": false 
	})
	RegType(TileType.Forest, {
		"name": "Forest",
		"walk": true,
		"walk_speed": 0.7,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.7,
		"can_have_builds": true,
		"have_builds": false 
	})
	RegType(TileType.Bigforest, {
		"name": "Big Forest",
		"walk": true,
		"walk_speed": 0.6,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.8,
		"can_have_builds": true,
		"have_builds": false 
	})
	RegType(TileType.Hills, {
		"name": "Hillsr",
		"walk": true,
		"walk_speed": 0.4,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.4,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Mountain, {
		"name": "Mountain",
		"walk": true,
		"walk_speed": 0.2,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.0,
		"can_have_builds": false,
		"have_builds": false 
	})
	RegType(TileType.Snowmountain, {
		"name": "Snow Mountain",
		"walk": false,
		"walk_speed": 0.0,
		"swim": false,
		"swim_speed": 0.0,
		"fertility": 0.0,
		"can_have_builds": false,
		"have_builds": false 
	})
	
func CreateCellData(type_id: int) -> CellData:
	var props = PropType.get(type_id, {})
	var data = CellData.new()
	
	data.tile_type = type_id
	data.name = props.get("name", "no name")
	data.walk = props.get("walk", false)
	data.walk_speed = props.get("walk_speed", 0.0)
	data.swim = props.get("swim", false)
	data.swim_speed = props.get("swim_speed", 0.0)
	data.fertility = props.get("fertility", 0.0)
	data.can_have_builds = props.get("can_have_builds", false)
	data.have_buids = props.get("have_builds", false)
	
	return data
	
func GetProp(type_id: int, prop_name: String):
	var props = PropType.get(type_id, {})
	return props.get(prop_name, null)

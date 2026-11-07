class_name CellData
extends Resource

#возможность и скорость ходьбы, плодородность, возможность строительства
var base_walk: bool = 0.0
var base_walk_speed: float = 0.0

var name: String = "no name"
var walk: bool = false
var walk_speed: float = base_walk
var fertility: float = base_walk_speed
var swim: bool = false
var swim_speed: float = 0.0
var can_have_builds: bool = false
var have_builds: bool = false

var tile_type: int = 1

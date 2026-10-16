class_name CitizenData
extends RefCounted

var id: int = 0
var name: String = ""
var gender: int = -1 # 1 - male; 0 - female 

var health: int = 100
var hunger_timer: float = 1.0
var hunger: int = 100

var position: Vector2i = Vector2i.ZERO
var world_position: Vector2 = Vector2.ZERO
var base_speed: float = 4.0 #tiles per second
var in_build_id: int = -1 # -1 - outdor

var wander_timer: float = 0.0
var path: Array[Vector2i] = []
var path_index: int = 0

var is_alive: bool = true

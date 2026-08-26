class_name CitizenData
extends RefCounted

var id: int = 0
var name: String = ""
var gender: int = -1 # 1 - male; 0 - female 

var health: float = 1.0
var hunger: float = 1.0

var position: Vector2i = Vector2i.ZERO
var in_build_id: int = -1 # -1 - outdor

var is_alive: bool = true

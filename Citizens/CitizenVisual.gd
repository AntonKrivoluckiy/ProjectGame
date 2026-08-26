class_name CitizenVisible
extends Node2D

var citizen_id: int = -1

@onready var sprite: AnimatedSprite2D = $CitizenTexture
  
func Setup(id: int):
	citizen_id = id
	UpdateDisplay()
	
func UpdateDisplay():
	var data = PopManager.GetCitizen(citizen_id)
	
	if data == null:
		return
		
	var tile_size = 16
	position = Vector2(
		data.position.x * tile_size + tile_size / 2.0,
		data.position.y * tile_size + tile_size / 2.0
	)

func _process(delta: float) -> void:
	if citizen_id != -1:
		UpdateDisplay()

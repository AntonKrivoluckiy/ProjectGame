class_name CitizenVisible
extends Area2D

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
	position = data.world_position

func _process(delta: float) -> void:
	if citizen_id != -1:
		UpdateDisplay()

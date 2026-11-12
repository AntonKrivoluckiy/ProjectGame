extends Panel

@onready var Seed: LineEdit = $SeedLine
@onready var Height: LineEdit = $HeightLine
@onready var Humidity: LineEdit = $HumidityLine
@onready var Rives: LineEdit = $RivesLine
@onready var Population: LineEdit = $PopulationLine

@onready var Start: Button = $StartButton
@onready var Back: Button = $BackButton

func _input(event: InputEvent) -> void:
	
	if Start.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main-Game.tscn")
	if Back.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		

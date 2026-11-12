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

func _input(event: InputEvent) -> void:
	
	if Start.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main-Game.tscn")
	if Back.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
		

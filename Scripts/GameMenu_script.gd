extends CanvasLayer

@onready var Heading: Label = $GameMenu/Heading
@onready var Continue: Button = $GameMenu/Continue_Button
@onready var SaveGame: Button = $GameMenu/SaveGame_Button
@onready var LoadGame: Button = $GameMenu/LoadGame_Button
@onready var Optios: Button = $GameMenu/Optios_Button
@onready var ExitToMenu: Button = $GameMenu/ExitToMenu_Button
@onready var Exit: Button = $GameMenu/ExitGame_Button

func _input(event: InputEvent) -> void:
	Continue.pressed.connect(func(): visible = false)
	if SaveGame.button_pressed:
		Heading.text = "Work in process"
	elif LoadGame.button_pressed:
		Heading.text = "Work in process"
	elif Optios.button_pressed:
		Heading.text = "Work in process"
	elif ExitToMenu.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	elif Exit.button_pressed:
		get_tree().quit()

func _ready() -> void:
	visible = false  # меню скрыто при входе в игру

func toggle() -> void:
	visible = not visible

func close() -> void:
	visible = false

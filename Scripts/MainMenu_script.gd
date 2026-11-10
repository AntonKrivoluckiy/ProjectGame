extends Panel

@onready var Heading: Label = $Heading
@onready var Continue: Button = $Continue_Button
@onready var SaveGame: Button = $SaveGame_Button
@onready var LoadGame: Button = $LoadGame_Button
@onready var Optios: Button = $Optios_Button
@onready var ExitToMenu: Button = $ExitToMenu_Button
@onready var Exit: Button = $ExitGame_Button

func _input(event: InputEvent) -> void:
	if Continue.button_pressed:
		Heading.text = "Work in process"
	elif SaveGame.button_pressed:
		Heading.text = "Work in process"
	elif LoadGame.button_pressed:
		Heading.text = "Work in process"
	elif Optios.button_pressed:
		Heading.text = "Work in process"
	elif ExitToMenu.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	elif Exit.button_pressed:
		get_tree().quit()

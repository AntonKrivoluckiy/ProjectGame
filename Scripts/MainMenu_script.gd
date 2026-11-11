extends Panel

@onready var Heading: Label = $Heading
@onready var Continue: Button = $Continue_Button
@onready var StartGame: Button = $StartGame_Button
@onready var LoadGame: Button = $LoadGame_Button
@onready var Optios: Button = $Optios_Button
@onready var Exit: Button = $Exit_Button

func _input(event: InputEvent) -> void:
	if Continue.button_pressed:
		Heading.text = "Work in process"
	elif StartGame.button_pressed:
		get_tree().change_scene_to_file("res://scenes/Main-Game.tscn")
	elif LoadGame.button_pressed:
		Heading.text = "Work in process"
	elif Optios.button_pressed:
		Heading.text = "Work in process"
	elif Exit.button_pressed or event.is_action_pressed("Exit"):
		get_tree().quit()

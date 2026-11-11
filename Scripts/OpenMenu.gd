extends Node2D

@onready var game_menu: CanvasLayer = $"MapGenerator/GameMenu"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):  # твоё действие на ESC
		game_menu.visible = not game_menu.visible
		get_viewport().set_input_as_handled()

extends CanvasLayer

@onready var food_layer: Label = $ResourcesUI/FoodUI

func _process(delta: float) -> void:
	var food_value = ResourcesManager.food
	
	food_layer.text = "Food: %.0f" % food_value

extends CanvasLayer

@onready var food_layer: Label = $ResourcesUI/FoodUI
@onready var wood_layer: Label = $ResourcesUI/WoodUI

func _process(delta: float) -> void:
	var food_value = ResourcesManager.food
	var wood_value = ResourcesManager.wood
	
	food_layer.text = "Food: %.0f" % food_value
	wood_layer.text = "Wood: %.0f" % wood_value

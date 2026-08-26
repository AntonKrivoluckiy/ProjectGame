class_name CitizenRender
extends Node2D

var citizen_scene: PackedScene = preload("res://Citizens/Сitizen.tscn")

var visible_nodes: Dictionary = {}

func _ready() -> void:
	print("CitizenRender ready, citizens count: ", PopManager.Citizens.size())
	PopManager.citizen_born.connect(_CitizenBorn)
	PopManager.citizen_diet.connect(_CitizenDiet)
	
	for id in PopManager.Citizens:
		print("Creating visual for existing citizen: ", id)
		CreateVisual(id)

func CreateVisual(citizen_id: int):
	if visible_nodes.has(citizen_id):
		return # уже есть
	
	var visual = citizen_scene.instantiate()
	visual.Setup(citizen_id)
	add_child(visual)
	visible_nodes[citizen_id] = visual

func RemoveVisual(citizen_id: int):
	if visible_nodes.has(citizen_id):
		visible_nodes[citizen_id].queue_free()
		visible_nodes.erase(citizen_id)

func _CitizenBorn(citizen_id: int):
	print("Signal citizen_born received for id: ", citizen_id)
	CreateVisual(citizen_id)

func _CitizenDiet(citizen_id: int):
	RemoveVisual(citizen_id)

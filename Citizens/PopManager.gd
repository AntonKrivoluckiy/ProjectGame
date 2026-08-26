extends Node

var Citizens: Dictionary = {}

var next_id: int = 0

signal citizen_born(citizen_id: int)
signal citizen_diet(citizen_id: int)
signal population_changed(new_count: int)

func CreateSitizen(cit_name: String, cit_position: Vector2i) -> int:
	var Citizen = CitizenData.new()
	
	Citizen.id = next_id
	Citizen.name = cit_name
	Citizen.position = cit_position
	
	Citizens[next_id] = Citizen
	citizen_born.emit(next_id)
	next_id += 1
	
	population_changed.emit(Citizens.size())
	return Citizen.id

func UpdateAllCitizens(delta_time: float):
	for Citizen in Citizens.values():
		Citizen.hunger = max(0.0, Citizen.hunger - 0.1)
		
		if Citizen.hunger <= 0.0:
			Citizen.health = max(0.0, Citizens.health - 0.1)
		
		if Citizen.health <= 0.0:
			Citizen.is_alive = false

var male_names: Array[String] = ["Tom", "Petr", "Ivan"]
var female_name: Array[String] = ["Elisa", "Alisa", "Maria"]

func GenerateRandomName(gender: int = -1) -> Dictionary:
	if gender == -1:
		gender = randi() % 2
	
	if gender == 1:
		var name = male_names[randi() % male_names.size()]
	else:
		var name = female_name[randi() % female_name.size()]
	
	return {"name": name}

func RemoveCitizen():
	var to_remove: Array[int] = []
	
	for id in Citizens:
		if not Citizens[id].is_alive:
			to_remove.append(id)
	
	for id in to_remove:
		KillCitizens(id)

func KillCitizens(id: int):
	if Citizens.has(id):
		Citizens.erase(id)
		citizen_diet.emit(id)
		population_changed.emit(Citizens.size())

func GetCitizen(id: int) -> CitizenData:
	return Citizens.get(id, null)

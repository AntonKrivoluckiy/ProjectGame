extends Node

var Citizens: Dictionary = {}

var next_id: int = 0

signal citizen_born(citizen_id: int)
signal citizen_diet(citizen_id: int)
signal population_changed(new_count: int)

func _process(delta: float) -> void:
	UpdateAllCitizens(delta)
	RemoveCitizen()

func CreateSitizen(cit_name: String, cit_gender: String, cit_position: Vector2i) -> int:
	var Citizen = CitizenData.new()
	
	Citizen.id = next_id
	Citizen.gender = cit_gender
	Citizen.name = cit_name
	Citizen.position = cit_position
	Citizen.world_position = Vector2(cit_position) * 16 + Vector2(8, 8)
	
	Citizen.wander_timer = randf() * 5.0
	
	Citizens[next_id] = Citizen
	citizen_born.emit(next_id)
	next_id += 1
	
	population_changed.emit(Citizens.size())
	return Citizen.id

func UpdateAllCitizens(delta_time: float):
	for Citizen in Citizens.values():
		#Simple Wander
		Citizen.wander_timer -= delta_time

		if Citizen.path.is_empty() and Citizen.wander_timer <= 0.0:
			var found_goal := false
			var target = Citizen.position
			var goal_attempt := 0
			
			while not found_goal and goal_attempt < 5:
				goal_attempt += 1
				var offset := Vector2i(randi_range(-5, 5), randi_range(-5, 5))
				if offset == Vector2i.ZERO:
					continue
				
				target = Citizen.position + offset
				if TileDatabase.IsWalkable(target):
					found_goal = true
			
			if not found_goal:
				Citizen.wander_timer = 5.0
			else:
				Citizen.path = BuildSimplePath(Citizen.position, target)
				if Citizen.path.is_empty():
					Citizen.wander_timer = 5.0
				else:
					Citizen.path_index = 0
					
		if not Citizen.path.is_empty():
			# на всякий случай, если index вдруг вылез
			if Citizen.path_index >= Citizen.path.size():
				Citizen.path.clear()
				Citizen.path_index = 0
				Citizen.wander_timer = 5.0
			else:
				var next_tile: Vector2i = Citizen.path[Citizen.path_index]
				var next_world: Vector2 = Vector2(next_tile) * 16.0 + Vector2(8, 8)
				
				var speed: float = Citizen.base_speed * 0.5 * TileDatabase.GetWalkSpeed(Citizen.position)
				speed = maxf(speed, 0.05)
				
				var to_target: Vector2 = next_world - Citizen.world_position
				if to_target.length() > 0.001:
					Citizen.world_position += to_target.normalized() * speed * 16.0 * delta_time
				
				if Citizen.world_position.distance_to(next_world) <= 2.0:
					Citizen.world_position = next_world
					Citizen.position = next_tile
					Citizen.path_index += 1
					
					if Citizen.path_index >= Citizen.path.size():
						Citizen.path.clear()
						Citizen.path_index = 0
						Citizen.wander_timer = 5.0
		
		# hunger
		Citizen.hunger_timer -= delta_time
		if Citizen.hunger_timer <= 0:
			Citizen.hunger = max(0, Citizen.hunger - 1)
			Citizen.hunger_timer = 1.0
		
		if Citizen.hunger < 30 and ResourcesManager.food >= 1:
			ResourcesManager.food -= 1
			Citizen.hunger += 70
			Citizen.hunger_timer = 10.0
			
		if Citizen.hunger <= 0 and ResourcesManager.food == 0:
			Citizen.health = max(0.0, Citizen.health - 1)
		
		# death
		if Citizen.health <= 0:
			Citizen.is_alive = false

var male_names: Array[String] = ["Tom", "Petr", "Ivan"]
var female_name: Array[String] = ["Elisa", "Alisa", "Maria"]

func GenerateRandomName(gender: int = -1) -> Dictionary:
	if gender == -1:
		gender = randi() % 2
	
	var s_gender: String
	var name: String
	if gender == 1:
		name = male_names[randi() % male_names.size()]
		s_gender = "Male"
	else:
		name = female_name[randi() % female_name.size()]
		s_gender = "Female"
	
	return {"name": name, "gender": s_gender}

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

func MarcCitizenDead(id: int):
	if Citizens.has(id):
		Citizens[id].is_alive = false
		RemoveCitizen()

func GetCitizen(id: int) -> CitizenData:
	return Citizens.get(id, null)

func find_citizen_at_tile(tile_pos: Vector2i) -> CitizenData:
	for citizen in Citizens.values():
		if citizen.is_alive and citizen.position == tile_pos:
			return citizen
	return null

# Simple Wander
func BuildSimplePath(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	# Уже на месте — путь не нужен
	if from == to:
		return []
	
	# Цель непроходима — смысла строить нет
	if not TileDatabase.IsWalkable(to):
		return []
	
	var path: Array[Vector2i] = []
	var current: Vector2i = from
	var visited: Dictionary = {}  # чтобы не ходить кругами
	visited[from] = true
	
	var max_steps: int = 30  # защита от бесконечного цикла
	var directions: Array[Vector2i] = [
		Vector2i(0, -1),  # вверх
		Vector2i(0, 1),   # вниз
		Vector2i(-1, 0),  # влево
		Vector2i(1, 0)    # вправо
	]
	
	for step in max_steps:
		if current == to:
			break
		
		var best_next: Vector2i = current
		var best_dist: int = 999999
		var found_any: bool = false
		
		# Смотрим всех соседей
		for dir in directions:
			var neighbor: Vector2i = current + dir
			
			# Уже были здесь — пропускаем
			if visited.has(neighbor):
				continue
			
			# Нельзя ходить
			if not TileDatabase.IsWalkable(neighbor):
				continue
			
			# Манхэттен: насколько далеко до цели
			var dist: int = absi(neighbor.x - to.x) + absi(neighbor.y - to.y)
			
			if dist < best_dist:
				best_dist = dist
				best_next = neighbor
				found_any = true
		
		# Застряли — пути нет
		if not found_any:
			return []
		
		# Делаем шаг
		current = best_next
		visited[current] = true
		path.append(current)
	
	# Если так и не дошли до цели — путь неполный, считаем неудачей
	if current != to:
		return []
	
	return path

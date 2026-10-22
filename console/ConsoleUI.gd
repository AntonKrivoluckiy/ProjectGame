extends Panel

@onready var history_label: RichTextLabel = $HistoryLabel
@onready var command_line: LineEdit = $CommandLine

var command_history: Array[String] = []
var history_index: int = -1

func _ready() -> void:
	visible = false
	command_line.text_submitted.connect(_on_command_submitted)
	add_message("Console ready. Type 'hello game' or 'help'")

func _on_command_submitted(command: String) -> void:
	if command.strip_edges() == "":
		return
		
	command_history.append(command)
	history_index = -1
	add_message("> " + command)
	execute_command(command)
	command_line.text = ""
	await get_tree().process_frame
	command_line.grab_focus()

func execute_command(command: String) -> void:
	var cam_pos = TileDatabase.CameraPosition()
	
	var parts = command.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	
	var map_gen = get_tree().root.find_child("MapGenerator", true, false)
	
	match cmd:
		#HELP
		"/help":
			add_message(
"List of commands:
- console - Work with console
	/hello game - hello gamer!
	/clear - Clear console
	/close - Close console
- region - Region DEBUG
	/region_info - Displaying information about the region
- spawn - Spawn entity 
	/spawn citizen - Spawn a citizen
- kill - Kill entity
	/kill citizens <num> - Kill <num> of citizens
- entity info - Entity DEBUG
	/citizen_info - Displaying information abouut the citizen
- add - add resources
	/add food <num> - Add <num> of food>
- del - delete resources
	/ del food <num> - Delete <num> of food"
		)
		
		#CONSOLE
		"/hello":
			if parts.size() > 1 and parts[1] == "game":
				add_message("Hello gamer!")
			else:
				add_message("Usage: /hello game")
		"/clear":
			history_label.clear()
		"/close":
			visible = false
			command_line.release_focus()
		
		# REGION
		"/region_info":
			map_gen.region_info_mode = not map_gen.region_info_mode
			map_gen.citizen_info_mode = false
			if map_gen.region_info_mode:
				add_message("Region info mode ON. Klick a tile to get info")
			else:
				add_message("Region info mode OFF")
		
		# SPAWN
		"/spawn":
			if parts.size() > 1 and parts[1] == "citizen":
				var cit_pos = Vector2i(cam_pos.x + randi() % 4, cam_pos.y + randi() % 4)
				var citizen_name = PopManager.GenerateRandomName()
				PopManager.CreateSitizen(
					citizen_name["name"],
					citizen_name["gender"],
					cit_pos
				)
				add_message("Citizen spawn on " + str(cit_pos))
			else:
				add_message("Try Usage: /spawn citizen")
				
		# KILL
		"/kill":
			if parts.size() > 1 and parts[1] == "citizens":
				if parts.size() > 2 and parts[2].is_valid_int():
					var count_to_kill = int(parts[2])
					
					var alive_ids: Array[int] = []
					for id in PopManager.Citizens:
						if PopManager.Citizens[id].is_alive:
							alive_ids.append(id)
							
					var actualy_kill = min(count_to_kill, alive_ids.size())
					
					for i in range(actualy_kill):
						PopManager.MarcCitizenDead(alive_ids[i])
					
					add_message(str(actualy_kill) + " citizens was killed")
			else:
				add_message("Try Ussage: /kill citizens <num>")
				
		# ENTITY INFO
		"/citizen_info":
			map_gen.citizen_info_mode = not map_gen.citizen_info_mode
			map_gen.region_info_mode = false
			if map_gen.citizen_info_mode:
				add_message("Citizen info on. Klick a citizen to get info")
			else:
				add_message("Citizen info mode off")
		
		# ADD RESOURCES
		"/add":
			if parts.size() > 1:
				if parts[1] == "food" and parts[2].is_valid_int():
					var add_food = int (parts[2])
					ResourcesManager.food += add_food
					add_message("Added " + str(add_food) + " food")
				else:
					add_message("Try Ussage: /add food <num>")
		
		# DEL RESOURCES
		"/del":
			if parts.size() > 1:
				if parts[1] == "food" and parts[2].is_valid_int():
					var del_food = int(parts[2])
					if del_food == -1:
						ResourcesManager.food = 0
						add_message("Deleted all food")
					else:
						ResourcesManager.food = max(0, ResourcesManager.food - del_food)
						add_message("Deleted " + str(del_food) + " food")
				else:
					add_message("Try Ussage: /del food <num>")
		
		"/spawn_building":
			var id = BuildManager.CreateBuilding("hut_2x2", cam_pos)
			if id >= 0:
				add_message("Building created id=%d at %s" % [id, str(cam_pos)])
				print(BuildManager.buildings)
			else:
				add_message("failed to create building")
		_:
			add_message("Unknown kommand: " + cmd + ". Ussage /help")

func add_message(text: String) -> void:
	history_label.append_text(text + "\n")
	await get_tree().process_frame
	history_label.scroll_to_line(history_label.get_line_count() - 1)

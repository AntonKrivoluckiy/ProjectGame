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
	
	var region_info_mode = false
	match cmd:
		"/hello":
			if parts.size() > 1 and parts[1] == "game":
				add_message("Hello game!")
			else:
				add_message("Usage: /hello game")
		"/help":
			add_message(
				"Доступные команды:
		/hello game
		/clear
		/close
		/region_info
		/free_cam"
		)
		"/clear":
			history_label.clear()
		"/close":
			visible = false
			command_line.release_focus()
		"/region_info":
			region_info_mode = not region_info_mode
			var map_gen = get_tree().root.find_child("MapGenerator", true, false)
			map_gen.region_info()
		"/spawn":
			if parts.size() > 1 and parts[1] == "citizen":
				var citizen_name = PopManager.GenerateRandomName()
				PopManager.CreateSitizen(
					citizen_name["name"],
					cam_pos
				)
				add_message("Citizen " + citizen_name["name"] + "spawn on (" + str(cam_pos) + ")")
			else:
				add_message("Try Usage: /spawn citizen")
		"/kill":
			if parts.size() > 1 and parts[1] == "citizen":
				if parts[2]:
					var count_of_deleted: int = int(parts[2])
					
					var all_ids = PopManager.Citizens.keys()
					var kills_id = min(count_of_deleted, all_ids.size())
					
					for id in range(kills_id):
						PopManager.Citizens[id].is_alive = false
					
					PopManager.RemoveCitizen()
			else:
				add_message("Try Ussage: /kill citizen (num)")
		_:
			add_message("Unknown kommand: " + cmd + ". Ussage /help")

func add_message(text: String) -> void:
	history_label.append_text(text + "\n")
	await get_tree().process_frame
	history_label.scroll_to_line(history_label.get_line_count() - 1)

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
		_:
			add_message("Неизвестная команда: " + cmd + ". Введите /help")

func add_message(text: String) -> void:
	history_label.append_text(text + "\n")
	await get_tree().process_frame
	history_label.scroll_to_line(history_label.get_line_count() - 1)

extends Node

# Ссылка на визуальную панель консоли (будет установлена после загрузки сцены)
var console_ui: Panel = null

# Флаг, что консоль готова к работе
var is_ready := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Console"):
		toggle()
		get_viewport().set_input_as_handled()

func _ready() -> void:
	if not get_tree():
		await get_tree().tree_entered
	get_tree().tree_changed.connect(_on_tree_changed)
	await get_tree().process_frame
	_find_console_ui()

func _on_tree_changed() -> void:
	if not get_tree():
		return
	await get_tree().process_frame
	_find_console_ui()

func _find_console_ui() -> void:
	# Ищем консоль в текущей сцене
	var found = get_tree().root.find_child("ConsoleUI", true, false)
	
	if found:
		# Если нашли новый объект или тот же самый
		if console_ui != found:
			console_ui = found
			is_ready = true
			console_ui.visible = false
			print("Console: найден ConsoleUI в текущей сцене")
	else:
		# Если не нашли, но старый объект ещё жив — возможно, он всё ещё в другой сцене
		if console_ui and is_instance_valid(console_ui):
			# Старая ссылка ещё валидна
			pass
		else:
			console_ui = null
			is_ready = false
			print("Console: ConsoleUI не найден в текущей сцене")


# Добавить сообщение в историю консоли
func add_message(text: String) -> void:
	if console_ui and console_ui.has_method("add_message"):
		console_ui.add_message(text)
	else:
		# fallback если консоль ещё не готова
		print("[CONSOLE] ", text)


# Очистить историю консоли
func clear() -> void:
	if console_ui and console_ui.has_method("clear_history"):
		console_ui.clear_history()
	else:
		print("[CONSOLE] clear() - метод не найден")


# Показать/скрыть консоль
func toggle() -> void:
	if not console_ui:
		return
	
	console_ui.visible = not console_ui.visible
	
	if console_ui.visible:
		# Фокусируемся на поле ввода
		var command_line = console_ui.get_node_or_null("CommandLine")
		if command_line and command_line is LineEdit:
			await get_tree().process_frame
			command_line.clear()
			command_line.grab_focus()
	else:
		var command_line = console_ui.get_node_or_null("CommandLine")
		if command_line:
			command_line.release_focus()


# Проверить, видна ли консоль
func is_visible() -> bool:
	return console_ui and console_ui.visible


# Отправить команду в консоль (программно)
func execute_command(command: String) -> void:
	if console_ui and console_ui.has_method("execute_command"):
		console_ui.execute_command(command)
	else:
		add_message("> " + command)
		add_message("Ошибка: консоль не готова выполнять команды")


# Включить/выключить режим отладки регионов (прокси в генератор)
func set_region_debug(enabled: bool) -> void:
	var map_gen = get_tree().root.find_child("MapGenerator", true, false)
	if map_gen and map_gen.has_method("enable_region_info") and map_gen.has_method("disable_region_info"):
		if enabled:
			map_gen.enable_region_info()
		else:
			map_gen.disable_region_info()
	else:
		add_message("Ошибка: MapGenerator не найден")

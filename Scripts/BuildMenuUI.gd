extends Panel

@onready var list: VBoxContainer = $List
@onready var bulldoze_btn: Button = $Bulldozer

var buttons: Dictionary = {}  # blueprint_id → Button

func _ready() -> void:
	_rebuild_list()
	bulldoze_btn.pressed.connect(_on_bulldoze)
	BuildManager.selection_changed.connect(_on_selection_changed)

func _rebuild_list() -> void:
	# очистить старые кнопки (если пересоберёшь список)
	for child in list.get_children():
		child.queue_free()
	buttons.clear()
	
	for bp_id in BuildManager.blueprints:
		var bp: Blueprint = BuildManager.blueprints[bp_id]
		var btn = Button.new()
		btn.text = bp.name  # "hut"
		btn.pressed.connect(_on_blueprint_pressed.bind(bp_id))
		list.add_child(btn)
		buttons[bp_id] = btn
	
	_refresh_button_states()

func _on_blueprint_pressed(blueprint_id: String) -> void:
	BuildManager.SelectBlueprint(blueprint_id)

func _on_bulldoze() -> void:
	BuildManager.ToggleBulldozeMode()
	_refresh_button_states()

func _on_selection_changed(_id: String) -> void:
	_refresh_button_states()

func _refresh_button_states() -> void:
	for bp_id in buttons:
		var btn: Button = buttons[bp_id]
		btn.modulate = Color(0.6, 1.0, 0.6) if BuildManager.IsSelected(bp_id) else Color.WHITE
	
	# подсветка бульдозера
	if BuildManager.bulldoze_mode:
		bulldoze_btn.modulate = Color(1.0, 0.5, 0.5)  # красноватый
	else:
		bulldoze_btn.modulate = Color.WHITE

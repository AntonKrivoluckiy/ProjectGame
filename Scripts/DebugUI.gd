extends CanvasLayer

@onready var fps_label: Label = $DebugUI/FPSLabel
@onready var mem_label: Label = $DebugUI/MemLabel
@onready var pos_label: Label = $DebugUI/PosLabel

func _process(delta: float) -> void:
	var FPS = Engine.get_frames_per_second()
	var Mem = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	var CamPos = TileDatabase.CameraPosition()
	
	fps_label.text = "FPS: %.1f" % FPS
	mem_label.text = "MEM: %.3f MB" % Mem
	pos_label.text = "Pos: (%d; %d)" % [CamPos.x, CamPos.y]

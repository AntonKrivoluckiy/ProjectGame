extends CanvasLayer

@onready var fps_label: Label = $DebugUI/FPSLabel
@onready var mem_label: Label = $DebugUI/MemLabel

func _process(delta: float) -> void:
	var FPS = Engine.get_frames_per_second()
	var Mem = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	
	fps_label.text = "FPS: %.1f" % FPS
	mem_label.text = "MEM: %.3f MB" % Mem

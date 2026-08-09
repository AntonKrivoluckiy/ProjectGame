extends Camera2D

var ZoomTarget: Vector2
var ZoomSpeed: float = 10

var MaxZoom = 4.0
var MinZoom = 1.0

var MapLeft = 0
var MapRight = 0
var MapUp = 0
var MapDown = 0

func update_bounds(width: int, height: int, tile_size: int = 16):
	MapLeft = 0
	MapRight = width * tile_size
	MapUp = 0
	MapDown = height * tile_size

var StartDragMousePosition = Vector2.ZERO
var StartDragCameraPosition = Vector2.ZERO
var isDraging : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ZoomTarget = zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Zoom(delta)
	SimplePan(delta)
	ClickAndDrag()
	
func Zoom(delta):
	var console = get_tree().root.find_child("ConsoleUI", true, false)
	if console and not console.visible:
		if Input.is_action_just_pressed("ZoomIn") and ZoomTarget.y < MaxZoom:
			ZoomTarget *= 1.1
		elif Input.is_action_just_pressed("ZoomOut") and ZoomTarget.y > MinZoom:
			ZoomTarget *= 0.9
		
	zoom = zoom.slerp(ZoomTarget, ZoomSpeed * delta)

func SimplePan(delta):
	var MoveAmount = Vector2.ZERO
	
	var console = get_tree().root.find_child("ConsoleUI", true, false)
	if console and not console.visible:
		if Input.is_action_pressed("MoveRight"):
			MoveAmount.x += 1
		if Input.is_action_pressed("MoveLeft"):
			MoveAmount.x -= 1
		if Input.is_action_pressed("MoveUp"):
			MoveAmount.y -= 1
		if Input.is_action_pressed("MoveDown"):
			MoveAmount.y += 1
		
	MoveAmount = MoveAmount.normalized()
	position += MoveAmount * delta * 3000 * (1/zoom.y)
	
	ClampPosition()
	
func ClickAndDrag():
	if not Console.is_visible():
		if !isDraging and Input.is_action_just_pressed("CameraPan"):
			StartDragMousePosition = get_viewport().get_mouse_position()
			StartDragCameraPosition = position
			isDraging = true
		
		if isDraging and Input.is_action_just_released("CameraPan"):
			isDraging = false
		
		if isDraging:
			var moveVector = get_viewport().get_mouse_position() -StartDragMousePosition
			position = StartDragCameraPosition - moveVector * 1/zoom.x
		
	ClampPosition()
	
func ClampPosition():
	if MapRight == 0 or MapDown == 0:
		return
	
	var half_width = get_viewport_rect().size.x / 2 * (1 / zoom.x)
	var half_height = get_viewport_rect().size.y / 2 * (1 / zoom.y)
	
	var min_x = MapLeft + half_width
	var max_x = MapRight - half_width
	var min_y = MapUp + half_height
	var max_y = MapDown - half_height
	
	var new_x = clamp(position.x, min_x, max_x)
	var new_y = clamp(position.y, min_y, max_y)
	
	position.x = new_x
	position.y = new_y

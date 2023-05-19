extends Polygon2D

var viewportSize
var positionDragStart

var dragging = false
var hovered = false
var dragLine: Polygon2D

var hovered_object = null

# Called when the node enters the scene tree for the first time.
func _ready():
	viewportSize = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (dragging):
		var mouseRelativePosition = get_viewport().get_mouse_position() - get_parent().global_position - get_parent().get_node("Sprite2D").texture.get_width() * 0.5 * Vector2.ONE
		polygon[2].x = mouseRelativePosition.length()
		polygon[3].x = mouseRelativePosition.length()
		rotation = mouseRelativePosition.angle()
		$DropArea.position.x = mouseRelativePosition.length()
		$DropArea.rotation = mouseRelativePosition.angle()

func _input(event):
	if event.is_action_pressed("click") && hovered:
		self.show()
		dragging = true
		SignalBus.emit_signal("unit_dragged", get_parent())

	if event.is_action_released("click") && dragging:
		self.hide()
		dragging = false
		$DropArea.position = Vector2.ZERO
		SignalBus.emit_signal("unit_dropped", get_parent(), hovered_object)

func _on_unit_mouse_entered():
	hovered = true

func _on_unit_mouse_exited():
	hovered = false

func _on_drop_area_entered(area):
	if dragging:
		hovered_object = area

func _on_drop_area_exited(area):
	if dragging:
		hovered_object = null

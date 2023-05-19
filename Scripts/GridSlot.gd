extends Area2D

var original_texture
var dragged_unit = null

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.unit_dragged.connect(self._on_unit_dragged.bind())
	$CollisionShape2D.disabled = true
	original_texture = $Sprite2D.texture

func set_available(status: bool):
	if status:
		$Sprite2D.modulate = Color(0, 1, 0)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)
		reset_texture()
	
	$CollisionShape2D.set_deferred("disabled", !status)

func has_socketed_unit():
	return get_child(-1) if get_child(-1).has_method("set_activity_timer") else null

func play_unit(unit):
	if !has_socketed_unit():
		socket_unit(unit)
		SignalBus.emit_signal("unit_played", unit, self)
	
func move_unit(unit):
	if !has_socketed_unit():
		socket_unit(unit)
		SignalBus.emit_signal("unit_moved", unit, self)

func socket_unit(unit):
	unit.reparent(self, false)
	unit.position = Vector2.ZERO

func add_dragged_unit_texture():
	$Sprite2D.texture = dragged_unit.get_node("Sprite2D").texture
	$Sprite2D.modulate.a = 0.4

func reset_texture():
	$Sprite2D.texture = original_texture
	$Sprite2D.modulate.a = 1

func _on_unit_dragged(unit):
	dragged_unit = unit

func _on_area_entered(area):
	if dragged_unit.is_ancestor_of(area):
		add_dragged_unit_texture()

func _on_area_exited(area):
	reset_texture()

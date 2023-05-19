extends Area2D

var original_texture

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.disabled = true
	original_texture = $Sprite2D.texture

func set_available(status: bool):
	if status:
		$Sprite2D.modulate = Color(0, 1, 0)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)
		reset_texture()
	
	$CollisionShape2D.set_deferred("disabled", !status)

func get_socketed_unit():
	return get_child(-1) if get_child(-1).has_method("is_in_play") else null

func socket_unit(unit):
	unit.reparent(self, false)
	unit.position = Vector2.ZERO

func add_unit_texture(unit):
	$Sprite2D.texture = unit.get_node("Sprite2D").texture
	$Sprite2D.modulate.a = 0.4

func reset_texture():
	$Sprite2D.texture = original_texture
	$Sprite2D.modulate.a = 1

func _on_area_entered(area):
	add_unit_texture(area.get_parent().get_parent())

func _on_area_exited(area):
	reset_texture()

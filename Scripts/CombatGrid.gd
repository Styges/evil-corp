extends Node2D

@export var slot_prefab: PackedScene
@export var rows_count: int = 4
@export var columns_count: int = 4
@export var margin_X: int = 10
@export var margin_Y: int = 10

var slots = []

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.unit_dropped.connect(self._on_unit_dropped.bind())
	SignalBus.unit_dragged.connect(self._on_unit_dragged.bind())
	
	for i in columns_count:
		var column = []
		for j in rows_count:
			var instance = slot_prefab.instantiate()
			add_child(instance)
			
			var slot_size = instance.get_node('Sprite2D').texture.get_size()
			instance.position.x = i * (slot_size.x + margin_X)
			instance.position.y = j * (slot_size.y + margin_Y)
			
			column.append(instance)
			
		slots.append(column)

func _on_unit_dragged(unit):
	for i in slots.size()/2:
		for slot in slots[i]:
			slot.set_available(true)

func _on_unit_dropped(unit, _dropped_on):
	for row in slots:
		for slot in row:
			slot.set_available(false)

extends Node2D

@export var slot_prefab: PackedScene
@export var rows_count: int = 4
@export var columns_count: int = 4
@export var deployment_columns: int = 2
@export var margin_X: int = 10
@export var margin_Y: int = 10

var slots = []
var unit_positions = {}
var temporary_unit_positions = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.turn_started.connect(self._on_turn_started)
	
	SignalBus.unit_dragged.connect(self._on_unit_dragged.bind())
	SignalBus.unit_dropped.connect(self._on_unit_dropped.bind())

	SignalBus.unit_played.connect(self._on_unit_played.bind())
	SignalBus.unit_moved.connect(self._on_unit_played.bind())
	SignalBus.unit_retreated.connect(self._on_unit_retreated.bind())
	
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

func is_unit_on_grid(unit):
	return unit_positions.keys().has(unit)
	
func get_available_move_slots(unit):
	var available_moves = []
	
	for column_index in columns_count:
		for row_index in rows_count:
			if (unit_positions[unit] - Vector2(column_index, row_index)).length() <= 2:
				available_moves.append(slots[column_index][row_index])
					
	return available_moves
	
func get_slot_position(slot):
	for column_index in columns_count:
		for row_index in rows_count:
			if slot == slots[column_index][row_index]:
				return Vector2(column_index, row_index)

func _on_turn_started():
	for key in temporary_unit_positions:
		unit_positions[key] = temporary_unit_positions[key]
		
	temporary_unit_positions = {}

func _on_unit_dragged(unit):
	if is_unit_on_grid(unit):
		for slot in get_available_move_slots(unit):
			slot.set_available(true)
	else:
		for i in deployment_columns:
			for slot in slots[i]:
				slot.set_available(true)

func _on_unit_dropped(unit, dropped_on):
	if is_unit_on_grid(unit) && dropped_on && dropped_on.has_method("move_unit"):
		dropped_on.move_unit(unit)

	for row in slots:
		for slot in row:
			slot.set_available(false)

func _on_unit_played(unit, slot):
	temporary_unit_positions[unit] = get_slot_position(slot)

func _on_unit_retreated(unit):
	unit_positions.erase(unit)

extends Area2D

@export var max_deploy_points = 4
var current_deploy_points = 0

var units = []
var units_to_lock = []
var locked_units = []

var margin_X: int = 3
var padding_X: int = 10
var padding_Y: int = 10
var unit_width = 0
var max_displayed: int = 4
var display_index: int = 0

var first_deployment: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.turn_started.connect(self._on_turn_started)
	
	SignalBus.unit_dropped.connect(self._on_unit_dropped.bind())
	SignalBus.unit_played.connect(self._on_unit_played.bind())
	SignalBus.unit_retreated.connect(self._on_unit_retreated.bind())
		
	add_deploy_points(max_deploy_points)
	
	for unit in UnitList.get_children():
		if !unit_width:
			unit_width = unit.get_node('Sprite2D').texture.get_size().x
		add_unit(unit)

func add_deploy_points(value: int):
	current_deploy_points = clamp(current_deploy_points + value, 0, max_deploy_points)
	$DeploymentPoints.text = str(current_deploy_points) + "/" + str(max_deploy_points)

func add_unit(unit):
	unit.reparent(self, false)
	units.append(unit)
	units.sort_custom(func(a, b): return a.deployment_cost < b.deployment_cost)
	add_display_index(-display_index)
	
func add_display_index(value: int):
	display_index += value
	$BoardNav/PreviousButton.disabled = display_index == 0
	$BoardNav/NextButton.disabled = display_index == units.size() - max_displayed
	refresh_units_display()

func refresh_units_display():
	$BoardNav.visible = units.size() > max_displayed
	
	if units.size() > max_displayed:
		for unit in units:
			unit.hide()
	else:
		display_index = 0
		
	for i in range(min(max_displayed, units.size())):
		units[display_index + i].show()
		units[display_index + i].position.x = i * (unit_width + margin_X) + padding_X
		units[display_index + i].position.y = padding_Y

func _on_unit_dropped(unit, dropped_on):
	if dropped_on != null:
		if !locked_units.has(unit) && dropped_on.has_method("play_unit") && unit.deployment_cost <= current_deploy_points:
			dropped_on.play_unit(unit)
			unit.set_activity_timer(unit.deployment_cost if !first_deployment else 0)
		if dropped_on == self:
			unit.set_retreat_timer(unit.deployment_cost if locked_units.has(unit) else 0)

func _on_unit_played(unit, slot):
	if !units_to_lock.has(unit):
		add_deploy_points(-unit.deployment_cost)
		units.erase(unit)
		units_to_lock.append(unit)
		refresh_units_display()

func _on_unit_retreated(unit):
	if locked_units.has(unit):
		unit.reparent(UnitList)
	else:
		add_unit(unit)
		add_deploy_points(unit.deployment_cost)
		units_to_lock.erase(unit)

func _on_turn_started():
	add_deploy_points(1)
	first_deployment = false
	locked_units.append_array(units_to_lock)
	units_to_lock = []
	
func _on_next_button_pressed():
	add_display_index(1)

func _on_previous_button_pressed():
	add_display_index(-1)

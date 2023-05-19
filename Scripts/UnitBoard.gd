extends Node2D

@export var max_deploy_points = 4
var current_deploy_points
var reinforcement_penalty = 1

var margin: int = 3
var max_displayed: int = 5

var slot_hovered = null
var unit_width = 0

var units
var display_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.turn_started.connect(self._on_turn_started)
	SignalBus.unit_dropped.connect(self._on_unit_dropped.bind())
	SignalBus.slot_hovered.connect(self._on_slot_hovered.bind())
	
	current_deploy_points = max_deploy_points
	
	units = UnitList.get_children()
	units.sort_custom(func(a, b): return a.deployment_cost < b.deployment_cost)
	
	for unit in units:
		unit.get_parent().remove_child(unit)
		add_child(unit)
		if !unit_width:
			unit_width = unit.get_node('Sprite2D').texture.get_size().x

	if units.size() <= max_displayed:
		$NavButtons.hide()
	
	refresh_units_display()

func refresh_units_display():
	hide_all_units()
	display_units()

func hide_all_units():
	for unit in units:
		unit.hide()

func display_units():
	for i in range(max_displayed):
		units[display_index + i].show()
		units[display_index + i].position.x = i * (unit_width + margin)

func _on_unit_dropped(unit):
	if !unit.is_on_play():
		if slot_hovered && slot_hovered.is_empty():
			play_unit(unit)
		
func play_unit(unit):
	if unit.deployment_cost <= current_deploy_points:
		current_deploy_points -= unit.deployment_cost
	else:
		unit.set_activity_timer(unit.deployment_cost - current_deploy_points + reinforcement_penalty)
		reinforcement_penalty += 1
		current_deploy_points = 0
	
	slot_hovered.add_unit(unit)
	slot_hovered = null

func _on_slot_hovered(slot, status):
	slot_hovered = slot if status else null

func _on_turn_started():
	reinforcement_penalty = 0

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for child in get_children():
			remove_child(child)
			UnitList.add_child(child)

func _on_next_button_pressed():
	display_index += 1
	refresh_units_display()
	
	$NavButtons/PreviousButton.disabled = false
	if display_index == units.size() - max_displayed:
		$NavButtons/NextButton.disabled = true

func _on_previous_button_pressed():
	display_index -= 1
	refresh_units_display()
	
	$NavButtons/NextButton.disabled = false
	if display_index == 0:
		$NavButtons/PreviousButton.disabled = true

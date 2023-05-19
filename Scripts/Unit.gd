extends Area2D

@export var deployment_cost = 1
@export var move_points = 1

var activity_timer = 0
var retreat_timer = 0

func _ready():
	SignalBus.turn_started.connect(self._on_turn_started)

func set_activity_timer(timer: int):
	activity_timer = timer
	$UnitUI.update_timer(activity_timer)
	
func set_retreat_timer(timer: int):
	retreat_timer = timer
	$UnitUI.update_timer(retreat_timer)
	
	if (retreat_timer == 0): 
		set_activity_timer(0)
		SignalBus.emit_signal("unit_retreated", self)
	
func _on_turn_started():
	if retreat_timer:
		set_retreat_timer(retreat_timer - 1)
	elif activity_timer:
		set_activity_timer(activity_timer - 1)
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		var parent = self.get_parent()
		if parent : 
			parent.remove_child(self)
			UnitList.set_child(self)

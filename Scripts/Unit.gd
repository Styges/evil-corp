extends Area2D

signal activity_timer_set(value: int)

@export var deployment_cost = 1
var activity_timer

var in_play:bool = false
var on_board:bool = false

func _ready():
	SignalBus.turn_started.connect(self._on_turn_started)
	set_activity_timer(0)
	
func is_in_play():
	return in_play
	
func is_on_board():
	return on_board
	
func set_on_board():
	on_board = true

func retreat():
	in_play = false
	on_board = false
	set_activity_timer(0)

func set_activity_timer(timer: int):
	activity_timer = timer
	activity_timer_set.emit(timer)
	
func _on_turn_started():
	if !in_play && on_board:
		in_play = true
	if activity_timer:
		set_activity_timer(activity_timer - 1)
	
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		var parent = self.get_parent()
		if parent : 
			parent.remove_child(self)
			UnitList.set_child(self)

extends Node2D

func pass_turn():
	SignalBus.emit_signal("turn_started")

func _on_next_button_pressed():
	pass_turn()

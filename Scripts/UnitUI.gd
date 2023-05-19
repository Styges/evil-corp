extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_unit_activity_timer_set(value):
	if !value:
		$Label.hide()
		$InactiveFilter.hide()
	else:
		$Label.show()
		$Label.text = str(value)
		$InactiveFilter.show()

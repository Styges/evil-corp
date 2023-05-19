extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	update_timer(0)

func init_ui(unit):
	pass

func update_timer(value):
	if !value:
		$InactiveFilter.hide()
	else:
		$InactiveFilter.show()
		$InactiveFilter/Timer.text = str(value)

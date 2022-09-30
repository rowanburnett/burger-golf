extends Control

onready var background = get_node("Background")
onready var foreground = get_node("Foreground")
onready var state = get_node("../../StateManager")

func _ready():
	state.connect("state_changed", self, "on_state_change")
	
func tell_power(power):
	foreground.rect_scale = Vector2(power / 3.0, 1)
	
func on_state_change(state):
	var is_power = state == StateManager.State.POWER
	background.visible = is_power
	foreground.visible = is_power

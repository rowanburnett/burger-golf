extends Control

func _on_States_aim_changed(x_angle, y_angle, direction, velocity):
	get_node("DirectionLabel").text = "Direction: %s" % direction
	get_node("AngleLabel").text = "Angle: %s" % x_angle

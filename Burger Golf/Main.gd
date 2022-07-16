extends Node

var power = 0
var direction = 0
var x_force = 0
var y_force = 0
var x_angle = 0.25
var y_angle = 0.25

onready var burger = get_node("Burger")
onready var powerLabel = get_node("Control/PowerLabel")
onready var directionLabel = get_node("Control/DirectionLabel")
onready var arrow = get_node("Burger/Arrow")
onready var camera = get_node("BurgerCamera")
onready var velocityLabel = get_node("Control/VelocityLabel")
onready var angleLabel = get_node("Control/AngleLabel")

func _process(delta):
	if Input.is_action_pressed("LEFT"):
		arrow.rotate_y(-0.02)
	if Input.is_action_pressed("RIGHT"):
		arrow.rotate_y(0.02)

	direction = -arrow.get_global_transform().basis.z
	
	if Input.is_action_pressed("hit_ball"):
		if power > -100:
			power -= 1
	else:
		if power < 0:
			power += 1
	
	if Input.is_action_pressed("UP"):
		if y_angle <= 0.5:
			x_angle -= 0.01
			y_angle += 0.01
	if Input.is_action_pressed("DOWN"):
		if x_angle <= 0.5:
			x_angle += 0.01
			y_angle -= 0.01
			
	powerLabel.text = "Power: %s" % (power / -1)
	directionLabel.text = "Direction: %s" % direction
	angleLabel.text = "Angle: %s" % x_angle
	velocityLabel.text = "Force: %s" % burger.forces[0]
	
	if Input.is_action_just_released("hit_ball"):
		x_force = (x_angle * power) / 2
		y_force = ((y_angle * power) / -1) / 2
		burger.launch(x_force, y_force)
		
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

extends Node

# Whether the power bar is going up or down currently
enum PowerDirection {
	INCREASING,
	DECREASING
}

var power = 0.0
var direction = 0
var x_force = 0
var y_force = 0
var x_angle = 0.25
var y_angle = 0.25

var power_direction = PowerDirection.INCREASING

onready var stateManager: StateManager = get_node("StateManager")
onready var burger = get_node("Burger")
onready var powerLabel = get_node("Control/PowerLabel")
onready var directionLabel = get_node("Control/DirectionLabel")
onready var arrow = get_node("Arrow")
onready var camera = get_node("CameraRig")
onready var velocityLabel = get_node("Control/VelocityLabel")
onready var angleLabel = get_node("Control/AngleLabel")
onready var power_bar = get_node("Control/PowerBar")

func _ready():
	stateManager.state = StateManager.State.AIMING

func _process(delta):
	if stateManager.state == StateManager.State.AIMING:
		aiming(delta);
	elif stateManager.state == StateManager.State.POWER:
		power(delta);
	elif stateManager.state == StateManager.State.WATCHING:
		watching(delta);
	
	powerLabel.text = "Power: %s" % power
	directionLabel.text = "Direction: %s" % direction
	angleLabel.text = "Angle: %s" % x_angle
	velocityLabel.text = "Force: %s" % burger.forces[0]
	
	
	if Input.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
		
func aiming(delta):
	if Input.is_action_pressed("LEFT"):
		arrow.rotate_y(-0.02)
	if Input.is_action_pressed("RIGHT"):
		arrow.rotate_y(0.02)

	direction = -arrow.get_global_transform().basis.z
	
	if Input.is_action_pressed("UP"):
		if y_angle <= 0.5:
			x_angle -= 0.01
			y_angle += 0.01
	if Input.is_action_pressed("DOWN"):
		if x_angle <= 0.5:
			x_angle += 0.01
			y_angle -= 0.01
	
	if Input.is_action_just_pressed("hit_ball"):
		stateManager.state = StateManager.State.POWER
	
func power(delta):
	if Input.is_action_just_pressed("hit_ball"):
		x_force = (x_angle * -power) / 2
		y_force = ((y_angle * -power) / -1) / 2
		burger.launch(x_force, y_force)
		stateManager.state = StateManager.State.WATCHING
		power_direction = PowerDirection.INCREASING
		power = 0
		
	if power_direction == PowerDirection.INCREASING:
		power += 0.05
		if power >= 3:
			power_direction = PowerDirection.DECREASING
	else:
		power -= 0.05
		if power <= 0:
			power_direction = PowerDirection.INCREASING
	power_bar.tell_power(power)
	
			
func watching(delta):
	# TODO idk if this method is robust to stuff like conveyer belts.
	#   Also we should probably check it stays static a few frames I guess
	#   It tends to detect it is not moving just before it does a bounce
	var stationaryTolerance = 0.005;
	var is_moving = burger.linear_velocity.length() > stationaryTolerance;
	if not is_moving:
		stateManager.state = StateManager.State.AIMING

	

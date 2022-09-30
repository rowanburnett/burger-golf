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

onready var stateManager: StateManager = get_node("../../StateManager")
var player = ""
var arrow = ""
var loaded = false

onready var player_node = get_node("../../Players")
onready var power_label = get_node("../../Control/PowerLabel")
onready var direction_label = get_node("../../Control/DirectionLabel")
onready var velocity_label = get_node("../../Control/VelocityLabel")
onready var angle_label = get_node("../../Control/AngleLabel")
onready var player_label = get_node("../../Control/PlayerLabel")
onready var power_bar = get_node("../../Control/PowerBar")

signal aim_changed()

func _ready():
	stateManager.state = StateManager.State.AIMING

func _process(delta):
	if loaded:
		if stateManager.state == StateManager.State.AIMING:
			aiming(delta);
		elif stateManager.state == StateManager.State.POWER:
			power(delta);
		elif stateManager.state == StateManager.State.WATCHING:
			watching(delta);
		
		power_label.text = "Power: %s" % power
		direction_label.text = "Direction: %s" % direction
		angle_label.text = "Angle: %s" % x_angle
	
func aiming(delta):
	if loaded:
		if Input.is_action_pressed("LEFT"):
			arrow.rotate_y(-0.02)
			emit_signal("aim_changed", x_angle, y_angle, direction)
		if Input.is_action_pressed("RIGHT"):
			arrow.rotate_y(0.02)

		direction = -arrow.get_global_transform().basis.z
		
		if Input.is_action_pressed("UP"):
			if y_angle <= 0.5:
				x_angle -= 0.01
				y_angle += 0.01
				emit_signal("aim_changed", x_angle, y_angle, direction)
		if Input.is_action_pressed("DOWN"):
			if x_angle <= 0.5:
				x_angle += 0.01
				y_angle -= 0.01
				emit_signal("aim_changed", x_angle, y_angle, direction)
		
		if Input.is_action_just_pressed("hit_ball"):
			stateManager.state = StateManager.State.POWER
			

func power(delta):
	if loaded: 
		if Input.is_action_just_pressed("hit_ball"):
			x_force = (x_angle * -power) / 2
			y_force = ((y_angle * -power) / -1) / 2
			print(x_force)
			player.launch(x_force, y_force)
			stateManager.state = StateManager.State.WATCHING
			power_direction = PowerDirection.INCREASING
			power = 0
			
		if power_direction == PowerDirection.INCREASING:
			power += 0.02
			if power >= 3:
				power_direction = PowerDirection.DECREASING
		else:
			power -= 0.02
			if power <= 0:
				power_direction = PowerDirection.INCREASING
		power_bar.tell_power(power)

var static_frames = 0

func watching(delta):
	print(static_frames)
	# TODO idk if this method is robust to stuff like conveyer belts.
	#   Also we should probably check it stays static a few frames I guess
	#   It tends to detect it is not moving just before it does a bounce
	var stationaryTolerance = 0.005;
	var is_moving = player.linear_velocity.length() > stationaryTolerance
	if not is_moving:
		static_frames += 1
		if static_frames >= 20:
			stateManager.state = StateManager.State.AIMING
			static_frames = 0
		
func _on_StateManager_next_turn(active_player):
	print(active_player)
	player = player_node.get_children()[active_player].get_node('RigidBody')
	arrow = player.get_node("../Arrow")
	player.get_node("../CameraRig/Camera").current = true
	player_label.text = "Player: %s" % Global.players[active_player].name

func _on_StateManager_state_changed(new_state):
	if loaded:
		var is_aiming = new_state == StateManager.State.AIMING
		arrow.visible = is_aiming

func _on_StateManager_loaded():
	# wait for players to be spawned in
	# there's definitely a better way to do this lol
	player = player_node.get_children()[0].get_node("RigidBody")
	arrow = player.get_node("../Arrow")
	player.get_node("../CameraRig/Camera").current = true
	player_label.text = "Player: %s" % Global.players[0].name
	for node in player_node.get_children():
		self.connect("aim_changed", node.get_node("Trajectory"), "_on_State_aim_changed")
	loaded = true

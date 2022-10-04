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

var player = NodePath()
var arrow = NodePath()
var loaded = false

onready var stateManager: StateManager = get_node("../../StateManager")
onready var player_node = get_node("../../Players")
onready var power_bar = get_node("../../Control/PowerBar")
onready var target = get_node("../../Target")
onready var player_label = get_node("../../Control/PlayerLabel")

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
		
func aiming(delta):
	if loaded:
		if Input.is_action_pressed("LEFT"):
			arrow.rotate_y(-0.02)
			emit_signal("aim_changed", x_angle, y_angle)
			
		if Input.is_action_pressed("RIGHT"):
			arrow.rotate_y(0.02)
			emit_signal("aim_changed", x_angle, y_angle)
		
		if Input.is_action_pressed("UP"):
			if y_angle <= 0.5:
				x_angle -= 0.01
				y_angle += 0.01
			emit_signal("aim_changed", x_angle, y_angle)
			
		if Input.is_action_pressed("DOWN"):
			if x_angle <= 0.5:
				x_angle += 0.01
				y_angle -= 0.01
			emit_signal("aim_changed", x_angle, y_angle)
		
		if Input.is_action_just_pressed("hit_ball"):
			stateManager.state = StateManager.State.POWER
			

func power(delta):
	if loaded: 
		if Input.is_action_just_pressed("hit_ball"):
			x_force = (x_angle * -power)
			y_force = (y_angle * -power) / -1
			player.launch(x_force, y_force)
			
			stateManager.state = StateManager.State.WATCHING
			power_direction = PowerDirection.INCREASING
			power = 0
			
		if power_direction == PowerDirection.INCREASING:
			power += 0.5
			if power >= 50:
				power_direction = PowerDirection.DECREASING
		else:
			power -= 0.5
			if power <= 0:
				power_direction = PowerDirection.INCREASING
		power_bar.tell_power(power)

var static_frames = 0

func watching(delta):
	# TODO idk if this method is robust to stuff like conveyer belts.
	#   Also we should probably check it stays static a few frames I guess
	#   It tends to detect it is not moving just before it does a bounce
	var stationaryTolerance = 0.005;
	var is_moving = player.get_node("RigidBody").linear_velocity.length() > stationaryTolerance
	if not is_moving:
		static_frames += 1
		if static_frames >= 20:
			stateManager.state = StateManager.State.AIMING
			static_frames = 0

func _on_StateManager_loaded(active_player):
	# wait for players to be spawned in
	# there's definitely a better way to do this lol
	get_active_player(active_player)
	for node in player_node.get_children():
		connect("aim_changed", node, "_on_aim_changed")
	loaded = true

func _on_StateManager_next_turn(active_player):
	get_active_player(active_player)

func _on_StateManager_state_changed(new_state):
	if loaded:
		var is_aiming = new_state == StateManager.State.AIMING
		arrow.visible = is_aiming

func get_active_player(active_player):
	player = player_node.get_children()[active_player]
	arrow = player.get_node("Arrow")
	player.get_node("CameraRig/Camera").current = true
	player_label.text = "Player: %s" % player.get_name()

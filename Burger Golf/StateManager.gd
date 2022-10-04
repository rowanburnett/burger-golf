extends Node

# Remembers the current state of the game
class_name StateManager

enum State {
	# Player is aiming
	AIMING,
	# Player is choosing their power
	POWER, 
	# Player has no control while the burger moves
	WATCHING
}

onready var burger = load("res://Burger.tscn")
onready var player_node = get_node("../Players")

signal state_changed(new_state)
signal next_turn(active_player)
signal loaded()

# List of players in the current game
var players = Global.players
#var players = [Player.new("Rowan")]
# index in 'players' of the active player
var active_player = 0
# What the active player is currently doing
var state = State.AIMING setget state_changed
	
func _ready():
	# make burger for each player
	for player in players:
		var instance = burger.instance()
		instance.set_name(player.name)
		player_node.add_child(instance)
		
	for node in player_node.get_children():
		self.connect("state_changed", node.get_node("RigidBody"), "_on_StateManager_state_changed")
	emit_signal("loaded", active_player)
	
func state_changed(new_state):
	emit_signal("state_changed", new_state)
	var old_state = state
	state = new_state
	var is_aiming = new_state == State.AIMING
	if state == State.AIMING and old_state == State.WATCHING:
		next_turn()
		
func next_turn():
	print("next turn")
	if active_player < len(players) - 1:
		active_player += 1
	else:
		active_player = 0
	emit_signal("next_turn", active_player)

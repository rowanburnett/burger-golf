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

class Player:
	var name: String
	
	func _init(name:String):
		self.name = name
		
signal state_changed(new_state)


# List of players in the current game
var players = [Player.new("Rowan")]
# index in 'players' of the active player
var active_player = 0
# What the active player is currently doing
var state = State.AIMING setget state_changed

func state_changed(new_state):
	emit_signal("state_changed", new_state)
	state = new_state
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

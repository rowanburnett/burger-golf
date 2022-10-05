extends Node

class Player:
	var name: String
	var active: bool
	
	func _init(name:String):
		self.name = name
		self.active = false
		
var players = [Player.new('Karl'), Player.new('Shrek'), Player.new('Boiled egg (jegg)'), Player.new('Donkey??')]

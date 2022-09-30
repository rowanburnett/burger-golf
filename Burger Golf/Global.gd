extends Node

class Player:
	var name: String
	
	func _init(name:String):
		self.name = name
		
var players = [Player.new('Karl'), Player.new('Shrek'), Player.new('Boiled egg (jegg)'), Player.new('Donkey??')]

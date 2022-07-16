extends Spatial

signal directionChange

func _process(delta):
	if rotation.x != 0:
		rotation.x = 0
		

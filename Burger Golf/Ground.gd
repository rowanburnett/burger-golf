extends CSGBox

signal collision

func _on_Burger_body_entered(body):
	emit_signal("collision")

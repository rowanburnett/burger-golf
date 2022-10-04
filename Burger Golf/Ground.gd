extends StaticBody

signal collision

func _on_Burger_body_entered(body):
	emit_signal("collision")

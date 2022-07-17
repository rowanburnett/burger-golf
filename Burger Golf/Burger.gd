extends RigidBody

var angle = Vector3.ZERO
var direction = Vector3.ZERO
var x_force = 0
var y_force = 0
var forces = [0, 0, 0]

onready var arrow = get_node("../Arrow")

func _ready():
	set_contact_monitor(true)
	
func _process(delta):
	direction = -arrow.get_global_transform().basis.z
	arrow.global_transform.origin = self.global_transform.origin
	
func launch(x_force, y_force):
	set_max_contacts_reported(1)
	
	apply_impulse(Vector3(0, 0.02, 0), direction * x_force)
	apply_impulse(Vector3.ZERO, Vector3(0, y_force, 0))
	
	forces = [x_force, y_force, direction]
	return forces

var bounces = 0

func _on_Ground_collision():
	return
	print("HELLO I AM COLLIDING")
	print(forces)
	if forces[0] < -2  or forces[1] > 2:
			forces[0] *= 0.8
			forces[1] *= 0.8
			print("FORCE")
			print(forces[1])
			apply_impulse(Vector3.ZERO, forces[0] * forces[2])
			apply_impulse(Vector3.ZERO, Vector3(0, forces[1], 0))
			


			
	else:
		set_max_contacts_reported(0)
		


func _on_StateManager_state_changed(new_state):
	var is_aiming = new_state == StateManager.State.AIMING
	arrow.visible = is_aiming

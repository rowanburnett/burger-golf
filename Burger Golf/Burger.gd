extends Spatial

var direction = Vector3.ZERO
var max_points = 250
var x_velocity = 0
var y_velocity = 0
var z_velocity = 0

var aim_changed = false

onready var burger = get_node("RigidBody")
onready var arrow = get_node("Arrow")
onready var line = get_node("Line")

func _process(delta):
	direction = -arrow.get_global_transform().basis.z
	arrow.global_transform.origin = burger.global_transform.origin

func _on_aim_changed(x_angle, y_angle):
	var x_force = (x_angle * -50)
	var y_force = (y_angle * 50)
	var z_force = (x_angle * -50)
	x_velocity = (x_force / burger.mass) * direction.x
	y_velocity = (y_force / burger.mass)
	z_velocity = (z_force / burger.mass) * direction.z
	
	aim_changed = true
	
func _physics_process(delta):
	if aim_changed:
		update_trajectory(delta)
		
func update_trajectory(delta):
	line.clear()
	line.begin(1)
	
	var pos = burger.translation
	var vel = Vector3(x_velocity, y_velocity, z_velocity)
	
	for i in max_points:
		line.add_vertex(pos)
		pos += vel * delta
		vel.x += x_velocity * delta
		vel.y -= y_velocity * delta - 9.8 * pow(delta, 2) / 2 
		vel.z += z_velocity * delta
		
	aim_changed = false
	line.end()
	
func launch(x_force, y_force):
	burger.apply_impulse(Vector3(0, 0.02, 0), Vector3(direction.x * x_force, y_force, direction.z * x_force))

extends Position3D

export var lerp_speed = 3.0
export (NodePath) var target_path = null
onready var burger = get_node("../Burger")
var target = null

func _ready():
	if target_path:
		target = get_node(target_path)

func _physics_process(delta):
	if !target:
		return
		
	var old_camera_pos = self.global_transform.origin
	var target_pos = target.global_transform.origin
	var new_camera_pos = lerp(old_camera_pos, target_pos, lerp_speed * delta)
	self.global_transform.origin = new_camera_pos
	self.rotation = target.rotation
	# self.rotation = Vector3(-target.rotation.x, -target.rotation.y, -target.rotation.z)
	
	
	
			
	# var target_pos = target.global_transform.translated(offset)
	# global_transform = global_transform.interpolate_with(target_pos, lerp_speed * delta)
	# look_at(target.global_transform.origin, Vector3.UP)

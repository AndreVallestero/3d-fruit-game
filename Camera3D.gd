extends Camera3D

const TAU = PI * 2
const SPEED = TAU / 3
const DROP_PLANE = Plane(0, 1, 0, 5)

var orbit_pos = 0
var player_pos = Vector3(0, 0, 0)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var ball = self.get_parent_node_3d().get_child(1)
		var dupe = ball.duplicate()
		dupe.position = player_pos
		self.get_parent_node_3d().add_child(dupe)

# Called every frame
func _process(delta):
	var input_dir = Input.get_axis("ui_left", "ui_right")
	orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
	position.x = sin(orbit_pos) * 10
	position.z = cos(orbit_pos) * 10
	rotation.y = orbit_pos
	
	var mouse_position = get_viewport().get_mouse_position()
	var plane_pos = DROP_PLANE.intersects_ray(
		self.project_ray_origin(mouse_position),
		self.project_ray_normal(mouse_position)
	)
	if plane_pos:
		player_pos = player_clamp(1, plane_pos)
	get_tree().get_root().get_node("Node3DRoot").get_node("Node3DPlayer").position = player_pos

func player_clamp(fruit_width, pos):
	var radius = fruit_width / 2.0
	return Vector3(
		clamp(pos.x, -5 + radius, 5 - radius),
		5,
		clamp(pos.z, -5 + radius, 5 - radius)
	)

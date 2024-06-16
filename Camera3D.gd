extends Camera3D

const TAU = PI * 2
const SPEED = TAU / 3
const DROP_PLANE = Plane(0, 1, 0, 5)

var orbit_pos = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = event.position
		var spawn_point = DROP_PLANE.intersects_ray(
			self.project_ray_origin(mouse_position),
			self.project_ray_normal(mouse_position)
		)
		var ball = self.get_parent_node_3d().get_child(1)
		var dupe = ball.duplicate()
		dupe.position = spawn_point
		self.get_parent_node_3d().add_child(dupe)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_dir = Input.get_axis("ui_left", "ui_right")
	orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
	position.x = sin(orbit_pos) * 10
	position.z = cos(orbit_pos) * 10
	rotation.y = orbit_pos

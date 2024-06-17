extends Node3D

const TAU = PI * 2
const SPEED = TAU / 3
const DROP_PLANE = Plane(0, 1, 0, 5)

var fruit_scene = preload("res://fruit.tscn")
var orbit_pos = 0
var camera
var player
var current_fruit
var current_radius
var marker_shape_cast: ShapeCast3D
var marker: MeshInstance3D

func _ready():
	camera = $Camera3D
	player = $Node3DPlayer
	marker_shape_cast = player.find_child("ShapeCast3D")
	marker = player.find_child("MeshInstance3D")
	spawn_fruit()
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		current_fruit.reparent(self)
		current_fruit.freeze = false
		current_fruit.find_child("CollisionShape3D").set_deferred("disabled", false)
		spawn_fruit()

# Called every frame
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var plane_pos = DROP_PLANE.intersects_ray(
		camera.project_ray_origin(mouse_pos),
		camera.project_ray_normal(mouse_pos)
	)
	if plane_pos:
		player.position = player_clamp(current_radius, plane_pos)
	marker.position.y = -10 * marker_shape_cast.get_closest_collision_safe_fraction() - current_radius
	
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir:
		orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
		camera.position.x = sin(orbit_pos) * 10
		camera.position.z = cos(orbit_pos) * 10
		camera.rotation.y = orbit_pos

func player_clamp(fruit_radius, pos):
	return Vector3(
		clamp(pos.x, -5 + fruit_radius, 5 - fruit_radius),
		5,
		clamp(pos.z, -5 + fruit_radius, 5 - fruit_radius)
	)
	
func spawn_fruit():
	current_fruit = fruit_scene.instantiate()
	current_fruit.set_tier(randi_range(0, 2))
	current_radius = current_fruit.find_child("CollisionShape3D").shape.radius
	player.add_child(current_fruit)
	

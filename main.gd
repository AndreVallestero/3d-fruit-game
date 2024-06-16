extends Node3D

const TAU = PI * 2
const SPEED = TAU / 3
const DROP_PLANE = Plane(0, 1, 0, 5)

var fruit_scene = preload("res://fruit.tscn")
var orbit_pos = 0
var camera
var player
var current_fruit

func _ready():
	camera = $Camera3D
	player = $Node3DPlayer
	spawn_fruit()
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		current_fruit.reparent(self)
		current_fruit.freeze = false
		current_fruit.find_child("CollisionShape3D").set_deferred("disabled", false)
		spawn_fruit()

# Called every frame
func _process(delta):
	var input_dir = Input.get_axis("ui_left", "ui_right")
	orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
	camera.position.x = sin(orbit_pos) * 10
	camera.position.z = cos(orbit_pos) * 10
	camera.rotation.y = orbit_pos
	
	var mouse_position = camera.get_viewport().get_mouse_position()
	var plane_pos = DROP_PLANE.intersects_ray(
		camera.project_ray_origin(mouse_position),
		camera.project_ray_normal(mouse_position)
	)
	if plane_pos:
		player.position = player_clamp(1, plane_pos)

func player_clamp(fruit_width, pos):
	var radius = fruit_width / 2.0
	return Vector3(
		clamp(pos.x, -5 + radius, 5 - radius),
		5,
		clamp(pos.z, -5 + radius, 5 - radius)
	)
	
func spawn_fruit():
	current_fruit = fruit_scene.instantiate()
	player.add_child(current_fruit)
	

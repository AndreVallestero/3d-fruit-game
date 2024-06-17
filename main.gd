extends Node3D

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
		player.position = player_clamp(plane_pos)
	marker.position.y = -10 * marker_shape_cast.get_closest_collision_safe_fraction() - current_fruit.radius
	
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir:
		orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
		camera.position.x = sin(orbit_pos) * 10
		camera.position.z = cos(orbit_pos) * 10
		camera.rotation.y = orbit_pos

func player_clamp(pos):
	return Vector3(
		clamp(pos.x, -5 + current_fruit.radius, 5 - current_fruit.radius),
		5,
		clamp(pos.z, -5 + current_fruit.radius, 5 - current_fruit.radius)
	)
	
func spawn_fruit():
	current_fruit = fruit_scene.instantiate()
	current_fruit.set_tier(randi_range(0, 2))
	current_fruit.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
	player.add_child(current_fruit)
	marker.mesh.outer_radius = current_fruit.radius
	marker.mesh.inner_radius = current_fruit.radius / 2 -0.01
	
func collision_detected(fruit1: RigidBody3D, fruit2: RigidBody3D):
	if fruit1.tier == fruit2.tier:
		var midpoint = fruit1.position + 0.5 * (fruit2.position - fruit1.position)
		remove_child(fruit2)
		fruit2.queue_free()
		fruit1.position = midpoint
		fruit1.update_tier(fruit1.tier + 1)
		fruit1.angular_velocity = Vector3.ZERO
		fruit1.linear_velocity = Vector3.ZERO
	

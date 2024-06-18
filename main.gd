extends Node3D

const HEIGHT = 16
const MAX_Y = HEIGHT / 2
const SPEED = TAU / 3
const DROP_PLANE = Plane(0, 1, 0, MAX_Y)
const GUIDE_FADE_DURATION = 3000
const DROP_COOLDOWN = 650
const OUT_OF_BOUND_TIME_LIMIT = 3000

var fruit_scene = preload("res://fruit.tscn")
var orbit_pos = 0
var camera
var player
var current_fruit
var marker_shape_cast: ShapeCast3D
var marker: MeshInstance3D
var guide_fade_time
var guide
var next_drop
var score = 0
var label_score
var collection
var end_game_time
var game_over

func _ready():
	camera = $Camera3D
	player = $Node3DPlayer
	guide = $LabelGuide
	label_score = $LabelScore
	collection = $Node3DFruitCollection
	marker_shape_cast = player.find_child("ShapeCast3D")
	marker = player.find_child("MeshInstance3D")
	spawn_fruit()
	
func _input(event):
	var current_time = Time.get_ticks_msec()
	if event is InputEventMouseButton and event.is_pressed() \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and (not next_drop or next_drop < current_time) \
			and not game_over:
		next_drop = current_time + DROP_COOLDOWN
		current_fruit.reparent(collection)
		current_fruit.freeze = false
		current_fruit.find_child("CollisionShape3D").set_deferred("disabled", false)
		add_score(sphere_volume(current_fruit.radius))
		spawn_fruit()
		trigger_guide_fade()
		
func _physics_process(_delta):
	var current_time = Time.get_ticks_msec()
	for node in collection.get_children():
		if node.position.y + node.radius > MAX_Y and (not next_drop or next_drop < current_time):
			if not end_game_time:
				end_game_time = current_time + OUT_OF_BOUND_TIME_LIMIT
				label_score.modulate = Color("red")
			elif current_time > end_game_time:
				end_game()
			return
	end_game_time = null
	label_score.modulate = Color("white")

# Called every frame
func _process(delta):
	# Mouse controls
	var mouse_pos = get_viewport().get_mouse_position()
	var plane_pos = DROP_PLANE.intersects_ray(
		camera.project_ray_origin(mouse_pos),
		camera.project_ray_normal(mouse_pos)
	)
	if plane_pos:
		player.position = player_clamp(plane_pos)
	marker.position.y = -HEIGHT * marker_shape_cast.get_closest_collision_safe_fraction() - current_fruit.radius
	
	# Camera controls
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if input_dir:
		orbit_pos = fmod(orbit_pos + input_dir * SPEED * delta, TAU)
		camera.position.x = sin(orbit_pos) * 10
		camera.position.z = cos(orbit_pos) * 10
		camera.rotation.y = orbit_pos
		trigger_guide_fade()
	
	# Update guide fade
	if guide_fade_time:
		guide.modulate.a = max(float(guide_fade_time - Time.get_ticks_msec() + GUIDE_FADE_DURATION) / GUIDE_FADE_DURATION, 0)

func player_clamp(pos):
	return Vector3(
		clamp(pos.x, -5 + current_fruit.radius, 5 - current_fruit.radius),
		HEIGHT/2,
		clamp(pos.z, -5 + current_fruit.radius, 5 - current_fruit.radius)
	)
	
func spawn_fruit():
	current_fruit = fruit_scene.instantiate()
	current_fruit.set_tier(randi_range(0, 2))
	current_fruit.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
	player.add_child(current_fruit)
	marker_shape_cast.shape.radius = current_fruit.radius
	marker.mesh.outer_radius = current_fruit.radius
	marker.mesh.inner_radius = current_fruit.radius / 2 -0.01
	
func trigger_guide_fade():
	if not guide_fade_time:
		guide_fade_time = Time.get_ticks_msec()

func add_score(amount):
	score += amount
	label_score.text = "Score: " + str(round(score))
	
func sphere_volume(radius):
	return 4 * PI * radius ** 3 / 3
	
func end_game():
	game_over = true
	for child in collection.get_children():
		child.freeze = true
	$Button.visible = true

# Restart
func _on_button_pressed():
	$Button.visible = false
	score = 0
	label_score.text = "Score: 0"
	for child in collection.get_children():
		collection.remove_child(child)
		child.queue_free()
	game_over = false
	guide_fade_time = null

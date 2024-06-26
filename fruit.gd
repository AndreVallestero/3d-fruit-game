extends RigidBody3D

const SQRT2 = sqrt(2)
const tier_mesh = [
	preload("res://meshes/mesh_godot.tres"),
	preload("res://meshes/mesh_krita.tres"),       #   4M users
	preload("res://meshes/mesh_thunderbird.tres"), #  20M users
	preload("res://meshes/mesh_firefox.tres"),     # 240M users
	preload("res://meshes/mesh_vlc.tres"),         # 300M users
	preload("res://meshes/mesh_tux.tres"),         # 1B+ servers
	preload("res://meshes/mesh_blender.tres"),     #   7M users, my friend wanted this to be the biggest
]

var tier
var radius
	
func set_tier(init_tier: int):
	self.tier = init_tier
	self.radius = SQRT2 ** init_tier / 2

func _ready():
	tier_mesh[tier].radius = self.radius
	tier_mesh[tier].height = self.radius * 2
	$MeshInstance3D.set_mesh(tier_mesh[tier])
	$CollisionShape3D.shape.radius = self.radius
	
func _on_body_entered(body):
	if body is RigidBody3D and tier == body.tier and tier < len(tier_mesh) - 1:
		# Remove other body
		var midpoint = position + 0.5 * (body.position - position)
		get_parent().remove_child(body)
		body.queue_free()
		var old_volume = sphere_volume(radius)
		
		# Update self
		position = midpoint
		set_tier(tier + 1)
		_ready()
		angular_velocity /= 4
		linear_velocity /= 4
		
		# Update score
		get_parent().get_parent().add_score(sphere_volume(radius) - old_volume)
		
		get_colliding_bodies().map(_on_body_entered) # recurse for new collisions
		
func sphere_volume(r):
	return 4 * PI * r ** 3 / 3

extends RigidBody3D

const SQRT2 = sqrt(2)
const tier_mesh = [
	preload("res://meshes/mesh_godot.tres"),
	preload("res://meshes/mesh_blender.tres"),
	preload("res://meshes/mesh_tux.tres"),
	preload("res://meshes/mesh_krita.tres"),
	preload("res://meshes/mesh_firefox.tres")
]

var tier
var radius
	
func set_tier(init_tier: int):
	self.tier = init_tier
	self.radius = SQRT2 ** init_tier / 2

func _ready():
	$MeshInstance3D.set_mesh(tier_mesh[tier])
	$CollisionShape3D.shape.radius = self.radius

func update_tier(new_tier: int):
	set_tier(new_tier)
	_ready()
	
func _on_body_entered(body):
	if body is RigidBody3D:
		get_parent().collision_detected(self, body as RigidBody3D)

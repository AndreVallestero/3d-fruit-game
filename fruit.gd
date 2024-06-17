extends RigidBody3D

const SQRT2 = sqrt(2)
const tier_mesh = [
	preload("res://meshes/mesh_godot.tres"),
	preload("res://meshes/mesh_blender.tres"),
	preload("res://meshes/mesh_tux.tres")
]

var tier
	
func set_tier(tier: int):
	self.tier = tier

func _ready():
	$MeshInstance3D.set_mesh(tier_mesh[tier])
	$CollisionShape3D.shape.radius = SQRT2 ** tier / 2

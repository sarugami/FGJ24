extends MeshInstance3D

var speed = 0.025

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_surface_override_material(0).uv1_offset.x += delta * speed
	get_surface_override_material(0).uv1_offset.y += delta * speed

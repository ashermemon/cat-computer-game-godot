@tool
extends EditorScenePostImport

func _post_import(scene):
	_add_smart_collisions(scene)
	return scene

func _add_smart_collisions(node: Node):
	if node is MeshInstance3D:
		var node_name = node.name.to_lower()
		
		# accurate for windows, doors, walls
		if "wall" in node_name or "door" in node_name or "window" in node_name:
			node.create_trimesh_collision()
			
		# optimized for everything else
		else:
			node.create_convex_collision()
	
	for child in node.get_children():
		_add_smart_collisions(child)

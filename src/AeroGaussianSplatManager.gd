class_name AeroGaussianSplatManager
extends "gaussian_splat_runtime.gd"

func load_splat(asset_path: String, parent: Node = null, options: Dictionary = {}) -> Dictionary:
	var load_result := create_splat_node_from_path(asset_path)
	if not load_result.get("ok", false):
		return load_result

	var node: Variant = load_result.get("node", null)
	if not (node is Node3D):
		return _error(ERR_BUG, "Gaussian splat load did not produce a Node3D instance")

	var placement_result := place_splat(node as Node3D, parent, options)
	if not placement_result.get("ok", false):
		if node != null and is_instance_valid(node):
			(node as Node).queue_free()
		return placement_result

	load_result["placed"] = placement_result.get("placed", false)
	load_result["transform_applied"] = placement_result.get("transform_applied", false)
	load_result["world_environment_configured"] = placement_result.get("world_environment_configured", false)
	return load_result

func place_splat(node: Node3D, parent: Node = null, options: Dictionary = {}) -> Dictionary:
	if node == null:
		return _error(ERR_INVALID_PARAMETER, "No gaussian splat node was provided for placement")

	if parent != null:
		if node.get_parent() == null:
			parent.add_child(node)
		elif node.get_parent() != parent:
			node.reparent(parent)

	var transform_applied := _apply_splat_options(node, options)
	var world_environment_configured := false
	var world_environment: Variant = options.get("world_environment", null)
	if world_environment is WorldEnvironment:
		configure_world_environment(world_environment as WorldEnvironment)
		world_environment_configured = world_environment.compositor != null and world_environment.compositor.compositor_effects.size() > 0

	return {
		"ok": true,
		"node": node,
		"placed": parent != null,
		"transform_applied": transform_applied,
		"world_environment_configured": world_environment_configured,
	}

func rotate_splat(node: Node3D, rotation_degrees: Vector3) -> Dictionary:
	if node == null:
		return _error(ERR_INVALID_PARAMETER, "No gaussian splat node was provided for rotation")
	node.rotation_degrees = rotation_degrees
	return {
		"ok": true,
		"node": node,
		"rotation_degrees": node.rotation_degrees,
	}

func unload_splat(node: Node) -> Dictionary:
	if node == null or not is_instance_valid(node):
		return _error(ERR_INVALID_PARAMETER, "No gaussian splat node was provided for unload")
	node.queue_free()
	return {
		"ok": true,
		"unloaded": true,
	}

func _apply_splat_options(node: Node3D, options: Dictionary) -> bool:
	var applied := false
	if options.has("position") and options["position"] is Vector3:
		node.position = options["position"]
		applied = true
	if options.has("rotation_degrees") and options["rotation_degrees"] is Vector3:
		node.rotation_degrees = options["rotation_degrees"]
		applied = true
	if options.has("scale") and options["scale"] is Vector3:
		node.scale = options["scale"]
		applied = true
	return applied

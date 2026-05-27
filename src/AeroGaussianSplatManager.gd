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
	load_result["parent"] = placement_result.get("parent", {})
	load_result["transform_applied"] = placement_result.get("transform_applied", false)
	load_result["transform"] = placement_result.get("transform", {})
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

	var transform_result := _apply_splat_options(node, options)
	if not transform_result.get("ok", false):
		return _error(ERR_INVALID_PARAMETER, String(transform_result.get("message", "Gaussian splat options were invalid")))

	var world_environment_configured := false
	var world_environment: Variant = options.get("world_environment", null)
	if world_environment is WorldEnvironment:
		configure_world_environment(world_environment as WorldEnvironment)
		world_environment_configured = world_environment.compositor != null and world_environment.compositor.compositor_effects.size() > 0

	return {
		"ok": true,
		"node": node,
		"placed": parent != null and node.get_parent() == parent,
		"parent": _build_parent_report(node),
		"transform_applied": transform_result.get("applied", false),
		"transform": _build_transform_report(node),
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
		"transform": _build_transform_report(node),
	}

func unload_splat(node: Node) -> Dictionary:
	if node == null or not is_instance_valid(node):
		return _error(ERR_INVALID_PARAMETER, "No gaussian splat node was provided for unload")
	node.queue_free()
	return {
		"ok": true,
		"unloaded": true,
	}

func _apply_splat_options(node: Node3D, options: Dictionary) -> Dictionary:
	var applied := false

	if options.has("position"):
		var position_result := _coerce_vector3_option(options["position"], "position")
		if not position_result.get("ok", false):
			return position_result
		node.position = position_result["value"]
		applied = true

	if options.has("rotation_degrees"):
		var rotation_degrees_result := _coerce_vector3_option(options["rotation_degrees"], "rotation_degrees")
		if not rotation_degrees_result.get("ok", false):
			return rotation_degrees_result
		node.rotation_degrees = rotation_degrees_result["value"]
		applied = true
	elif options.has("rotation"):
		var rotation_result := _coerce_vector3_option(options["rotation"], "rotation")
		if not rotation_result.get("ok", false):
			return rotation_result
		node.rotation = rotation_result["value"]
		applied = true

	if options.has("scale"):
		var scale_result := _coerce_vector3_option(options["scale"], "scale")
		if not scale_result.get("ok", false):
			return scale_result
		node.scale = scale_result["value"]
		applied = true

	return {
		"ok": true,
		"applied": applied,
	}

func _coerce_vector3_option(value: Variant, option_name: String) -> Dictionary:
	if value is Vector3:
		return {
			"ok": true,
			"value": value,
		}
	if value is Array and value.size() == 3:
		return {
			"ok": true,
			"value": Vector3(float(value[0]), float(value[1]), float(value[2])),
		}
	if value is Dictionary and value.has("x") and value.has("y") and value.has("z"):
		return {
			"ok": true,
			"value": Vector3(float(value["x"]), float(value["y"]), float(value["z"])),
		}
	return {
		"ok": false,
		"message": "Gaussian splat option '%s' must be a Vector3, [x, y, z] array, or {x, y, z} dictionary" % option_name,
	}

func _build_transform_report(node: Node3D) -> Dictionary:
	var parent_node := node.get_parent_node_3d()
	return {
		"position": node.position,
		"rotation": node.rotation,
		"rotation_degrees": node.rotation_degrees,
		"scale": node.scale,
		"global_position": node.global_position if node.is_inside_tree() else node.position,
		"global_rotation": node.global_rotation if node.is_inside_tree() else node.rotation,
		"global_rotation_degrees": node.global_rotation_degrees if node.is_inside_tree() else node.rotation_degrees,
		"global_scale": node.global_basis.get_scale() if node.is_inside_tree() else node.scale,
		"parent_name": parent_node.name if parent_node != null else "",
	}

func _build_parent_report(node: Node3D) -> Dictionary:
	var parent_node := node.get_parent()
	if parent_node == null:
		return {
			"attached": false,
			"name": "",
			"path": "",
		}
	return {
		"attached": true,
		"name": String(parent_node.name),
		"path": String(parent_node.get_path()) if node.is_inside_tree() else String(parent_node.name),
	}

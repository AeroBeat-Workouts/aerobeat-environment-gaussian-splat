extends Node3D

var _tool_manager: AeroGaussianSplatManager
var _world_environment: WorldEnvironment
var _camera: Camera3D
var _loaded_splat: Node3D

func _ready() -> void:
	_tool_manager = AeroGaussianSplatManager.new()
	add_child(_tool_manager)
	_setup_scene()

	var sample_path := ProjectSettings.globalize_path("res://assets/splats/demo.ply")
	var result := _tool_manager.load_splat(sample_path, self, {
		"position": Vector3.ZERO,
		"rotation_degrees": Vector3(0.0, 45.0, 0.0),
		"world_environment": _world_environment,
	})
	if result.get("ok", false):
		_loaded_splat = result.get("node", null)
		print("Gaussian splat load ok: %s (%d points, support=%s)" % [sample_path, int(result.get("point_count", 0)), String(_tool_manager.get_renderer_support_status().get("support_level", "unknown"))])
	else:
		push_warning(result.get("message", "Unknown splat load failure"))

func _setup_scene() -> void:
	_camera = Camera3D.new()
	_camera.look_at_from_position(Vector3(0.0, 0.0, 4.0), Vector3.ZERO)
	add_child(_camera)

	_world_environment = WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.07, 0.09)
	_world_environment.environment = env
	add_child(_world_environment)

	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	add_child(light)

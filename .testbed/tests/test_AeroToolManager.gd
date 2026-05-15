extends GutTest

const SAMPLE_PLY := "res://assets/splats/demo.ply"

func test_tool_manager_initializes_and_exposes_supported_formats() -> void:
	var manager := AeroToolManager.new()
	manager._initialize()
	assert_true(manager._is_initialized, "Manager should initialize")
	assert_true(manager.get_supported_extensions().has("ply"), "PLY should be supported")
	assert_true(manager.get_supported_extensions().has("splat"), "Legacy .splat should be supported")
	manager.free()

func test_absolute_path_loading_builds_a_resource() -> void:
	var manager := AeroToolManager.new()
	manager._initialize()
	var absolute_path := ProjectSettings.globalize_path(SAMPLE_PLY)
	var result := manager.load_gaussian_resource_from_path(absolute_path)
	assert_true(result.get("ok", false), result.get("message", "Expected sample PLY to load"))
	assert_true(result.get("point_count", 0) > 0, "Loaded sample should contain points")
	assert_true(result.get("resource", null) != null, "Resource should be returned")
	manager.free()

func test_configure_world_environment_persists_compositor_effect_once() -> void:
	var manager := AeroToolManager.new()
	manager._initialize()
	var world_environment := WorldEnvironment.new()

	manager.configure_world_environment(world_environment)

	assert_not_null(world_environment.compositor, "World environment should get a compositor")
	assert_eq(world_environment.compositor.compositor_effects.size(), 1, "Gaussian compositor effect should persist on the compositor")
	var effect: CompositorEffect = world_environment.compositor.compositor_effects[0]
	assert_not_null(effect.get_script(), "Configured compositor effect should have the gdgs script attached")
	assert_eq(effect.get_script().resource_path, "res://addons/gdgs/runtime/compositor/gaussian_compositor_effect.gd", "Configured compositor effect should point at the gdgs compositor script")

	manager.configure_world_environment(world_environment)
	assert_eq(world_environment.compositor.compositor_effects.size(), 1, "Configuring the same world environment twice should not duplicate the compositor effect")
	world_environment.free()
	manager.free()

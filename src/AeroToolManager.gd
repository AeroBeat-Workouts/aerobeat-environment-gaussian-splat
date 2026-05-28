extends Node

const AeroGaussianSplatManagerScript = preload("AeroGaussianSplatManager.gd")
const AeroGaussianSplatEnvironmentFulfillmentScript = preload("AeroGaussianSplatEnvironmentFulfillment.gd")

var _gaussian_manager: AeroGaussianSplatManager
var _fulfillment: AeroGaussianSplatEnvironmentFulfillment

func _ready() -> void:
	_ensure_runtime()

func fulfill(request: Variant) -> Variant:
	return _ensure_fulfillment().fulfill(request)

func begin_fulfill(request: Variant) -> Variant:
	return _ensure_fulfillment().begin_fulfill(request)

func get_renderer_support_status() -> Dictionary:
	return _ensure_manager().get_renderer_support_status()

func get_gaussian_manager() -> AeroGaussianSplatManager:
	return _ensure_manager()

func _ensure_runtime() -> void:
	_ensure_manager()
	_ensure_fulfillment()

func _ensure_manager() -> AeroGaussianSplatManager:
	if _gaussian_manager == null:
		_gaussian_manager = AeroGaussianSplatManagerScript.new()
		add_child(_gaussian_manager)
	return _gaussian_manager

func _ensure_fulfillment() -> AeroGaussianSplatEnvironmentFulfillment:
	if _fulfillment == null:
		_fulfillment = AeroGaussianSplatEnvironmentFulfillmentScript.new(_ensure_manager())
	return _fulfillment

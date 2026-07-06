extends Node3D
class_name Wand

@onready var beam: MeshInstance3D = $BeamStart/Beam
@onready var beam_start: Node3D = $BeamStart

@export var max_length = 200.0
@export var beam_speed = 175.0

var is_casting = false
var target_point: Vector3

func _process(delta: float) -> void:
	if is_casting:
		beam.visible = true

		var direction = target_point - beam_start.global_position
		var distance = clamp(direction.length(), 0.0, max_length)

		beam.mesh.height = move_toward(beam.mesh.height, distance, delta * beam_speed)
		#beam.scale.y = move_toward(beam.scale.y, distance, delta * beam_speed)
		beam.position = Vector3(0, beam.mesh.height / 2.0, 0)

		if direction.length() > 0.01:
			var dir_normalized = direction.normalized()
			var right = dir_normalized.cross(Vector3.UP)
			if right.length() < 0.01:
				right = dir_normalized.cross(Vector3.RIGHT)
			right = right.normalized()
			var up = right.cross(dir_normalized)
			beam_start.global_transform.basis = Basis(right, dir_normalized, up).orthonormalized()
	else:
		beam.mesh.height = move_toward(beam.mesh.height, 0.0, delta * beam_speed)
		beam.position = Vector3(0, beam.mesh.height / 2.0, 0)
		if beam.mesh.height < 0.05:
			beam.visible = false

func set_is_casting(val: bool):
	is_casting = val

func set_target(target: Vector3):
	target_point = target

extends Node3D
class_name Wand

@onready var beam: MeshInstance3D = $BeamStart/Beam
@onready var beam_start: Node3D = $BeamStart

@export var max_length = 10.0
@export var beam_speed = 20.0

var is_casting = false
var target_point: Vector3

var original_rotation: Vector3

func _ready() -> void:
	original_rotation = rotation

func _process(delta: float) -> void:
	if is_casting:
		beam.visible = true
		print(target_point)
		var direction = target_point - beam_start.global_position
		print(direction)
		var distance = clamp(direction.length(), 0.0, max_length)
		print(distance)
#
		beam.mesh.height = move_toward(beam.mesh.height, distance, delta * beam_speed)
		
		if distance > 0.01:
			beam_start.look_at(target_point, Vector3.UP)
			beam_start.rotate_object_local(-Vector3.RIGHT, PI / 2)
	else:
		if beam.mesh.height < 0.05:
			beam.visible = false
			beam_start.rotation = Vector3.ZERO
			return
		beam.mesh.height = lerp(beam.mesh.height, 0.0, delta * beam_speed)
	beam.position = Vector3(0, beam.mesh.height / 2.0, 0)
	

func set_is_casting(val: bool):
	is_casting = val

func set_target(target: Vector3):
	target_point = target

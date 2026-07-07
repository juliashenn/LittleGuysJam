extends RigidBody3D
class_name Grabbable

var grabbed = false
var player: Player
@export var grab_speed = 30.0
@export var note: Note = preload("res://Resources/QuarterNotes/D4 Q.tres")
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	audio.stream = load(note.audioFile)
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if grabbed:
		#if (global_position-player.grab_point.global_position).length() > 0.1:
			#global_position = global_position.move_toward(player.grab_point.global_position, delta * grab_speed)
		#look_at(player.camera.global_position, Vector3.UP)
		var target = player.grab_point.global_position
		var displacement = target - global_position
		linear_velocity = displacement * grab_speed
		
		var target_basis = Basis.looking_at(player.camera.global_position - global_position, Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, delta * grab_speed)
		angular_velocity = Vector3.ZERO 
	
func grab():
	grabbed = true
	#freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	#freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func drop():
	grabbed = false
	freeze = false
	
func poke():
	audio.play(0.0)

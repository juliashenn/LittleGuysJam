extends RigidBody3D
class_name Grabbable

var grabbed = false
var player: Player
@export var grab_speed = 30.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if grabbed:
		global_position = global_position.move_toward(player.grab_point.global_position, delta * grab_speed)
		look_at(player.camera.global_position, Vector3.UP)

func grab():
	grabbed = true
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func drop():
	grabbed = false
	freeze = false

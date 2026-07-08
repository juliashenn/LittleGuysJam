extends RigidBody3D
class_name Grabbable

var grabbed = false
var player: Player
@export var grab_speed = 30.0
@export var note: Note = preload("res://Resources/QuarterNotes/D4 Q.tres")
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var mesh: Node3D

var start_scale
func _ready() -> void:
	if mesh:
		start_scale = mesh.scale
	audio.stream = load(note.audioFile)
	player = get_tree().get_first_node_in_group("player")
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

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
	freeze = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func drop():
	grabbed = false
	freeze = false
	
func poke():
	audio.play(0.0)
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3(1, 0.7, 1)*start_scale, 0.2)
	tween.tween_property(mesh, "scale", start_scale, 0.3)
	
func bounce():
	var start_pos = mesh.position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(mesh, "position", start_pos + Vector3(0, 0.5, 0), 0.35)
	tween.parallel().tween_property(mesh, "scale", Vector3(0.85, 1.2, 0.85) * start_scale, 0.35)
	
	tween.tween_property(mesh, "scale", start_scale, 0.15)
	
	tween.tween_property(mesh, "scale", Vector3(0.9, 0.85, 0.9) * start_scale, 0.1)
	tween.tween_property(mesh, "position", start_pos, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(mesh, "scale", Vector3(1.3, 0.65, 1.3) * start_scale, 0.2)
	
	tween.tween_property(mesh, "scale", start_scale, 0.15).set_ease(Tween.EASE_OUT)
	#tween.parallel().tween_property(mesh, "position", start_pos + Vector3(0, 1, 0), 0.4)
	#tween.parallel().tween_property(mesh, "scale", Vector3(1, 1.1, 1) * start_scale, 0.4)
	#tween.tween_property(mesh, "position", start_pos, 0.3)
	#tween.parallel().tween_property(mesh, "scale", Vector3(1.2, 0.7, 1.2) * start_scale, 0.3)
	#tween.tween_property(mesh, "scale", start_scale, 0.15)
	audio.play(0.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground"):
		if mesh:
			#linear_velocity = Vector3.ZERO
			#angular_velocity = Vector3.ZERO
			var tween = create_tween()
			tween.tween_property(mesh, "scale", Vector3(1, 0.7, 1)*start_scale, 0.2)
			tween.tween_property(mesh, "scale", start_scale, 0.3)

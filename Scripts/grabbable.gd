extends RigidBody3D
class_name Grabbable

var grabbed = false
var player: Player
@export var grab_speed = 30.0
@export var note: Note 
@export var audio: AudioStreamPlayer3D
@export var mesh: Node3D
@export var squish_speed = 1.0

var active_tween

var start_scale
func _ready() -> void:
	if mesh:
		start_scale = mesh.scale
	if note:
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
		
		var dir = player.camera.global_position - global_position
		if dir.length() > 0.01:
			var target_basis = Basis.looking_at(dir, Vector3.UP).orthonormalized()
			global_transform.basis = global_transform.basis.orthonormalized().slerp(target_basis, delta * grab_speed).orthonormalized()		
		angular_velocity = Vector3.ZERO 
	
func grab():
	set_collision_layer_value(3, false)
	set_collision_mask_value(3, false)
	grabbed = true
	#freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func drop():
	set_collision_layer_value(3, true)
	set_collision_mask_value(3, true)
	grabbed = false
	freeze = false
	
func poke():
	if active_tween: active_tween.kill()
	mesh.position = Vector3.ZERO
	mesh.scale = start_scale
	audio.play(0.0)
	active_tween = create_tween()
	active_tween.tween_property(mesh, "scale", Vector3(1, 0.7, 1)*start_scale, 0.2/squish_speed)
	active_tween.tween_property(mesh, "scale", start_scale, 0.3/squish_speed)
	
func bounce():
	if active_tween: active_tween.kill()
	mesh.position = Vector3.ZERO
	mesh.scale = start_scale
	var start_pos = mesh.position
	active_tween = create_tween()
	active_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	active_tween.parallel().tween_property(mesh, "position", start_pos + Vector3(0, 0.5, 0), 0.35/squish_speed)
	active_tween.parallel().tween_property(mesh, "scale", Vector3(0.85, 1.2, 0.85) * start_scale, 0.35/squish_speed)
	
	active_tween.tween_property(mesh, "scale", start_scale, 0.15/squish_speed)
	
	active_tween.tween_property(mesh, "scale", Vector3(0.9, 0.85, 0.9) * start_scale, 0.1/squish_speed)
	active_tween.tween_property(mesh, "position", start_pos, 0.2/squish_speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	active_tween.parallel().tween_property(mesh, "scale", Vector3(1.3, 0.65, 1.3) * start_scale, 0.2/squish_speed)
	
	active_tween.tween_property(mesh, "scale", start_scale, 0.15/squish_speed).set_ease(Tween.EASE_OUT)
	audio.play(0.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground"):
		poke()

func set_note(n: Note):
	if not n: return
	note = n
	audio.stream = load(note.audioFile)

extends Node3D
class_name Bird

@onready var interactable: Interactable = $Area3D
@onready var marker: Marker3D = $Marker3D
@onready var heart: Node3D = $"PUMPING HEART MODEL"
@onready var heart_anim: AnimationPlayer = $AnimationPlayer

@export var fly_speed: float = 10.0
@export var bird_ind: int
@export var birds: Array[Node3D] = []
@export var anims: Array[AnimationPlayer] = []
var anim_prefix: String = ""
var found_bird_num: int
var holding_note: Grabbable
var discovered: bool = false
var gazebo: Gazebo
var active_tween: Tween
var player: Player
var heading_home := false
var following_player := false

func _ready() -> void:
	disable_heart()
	interactable.is_interactable = true
	interactable.interact = on_interact
	set_bird(randi() % birds.size())
	idle()
	gazebo = get_tree().get_first_node_in_group("gazebo") as Gazebo
	player = get_tree().get_first_node_in_group("player") as Player

func on_interact():
	heart_anim.play("heart")
	discovered = true
	var player = get_tree().get_first_node_in_group("player") as Player
	found_bird_num = player.found_birds.size()
	player.found_birds.append(self)
	interactable.is_interactable = false
	await get_tree().create_timer(1.0).timeout
	return_to_base()

func set_bird(i: int):
	bird_ind = i
	for x in range(birds.size()):
		if x == i:
			birds.get(x).visible = true
			var name = birds.get(x).name
			anim_prefix = name+"|"+name+"|"+name+"|"
		else:
			birds.get(x).visible = false

func fly():
	anims.get(bird_ind).play(anim_prefix+"fly")
	
func idle():
	anims.get(bird_ind).play(anim_prefix+"idle")

func _process(delta: float) -> void:
	if holding_note:
		holding_note.global_position = marker.global_position
		holding_note.rotation = Vector3.ZERO
	if following_player:
		global_position = global_position.move_toward(player.bird_marker.global_position, delta*fly_speed)
		var dir = player.camera.global_position - global_position
		if dir.length() > 0.01:
			var target_basis = Basis.looking_at(dir, Vector3.UP).orthonormalized()
			global_transform.basis = global_transform.basis.orthonormalized().slerp(target_basis, delta * fly_speed).orthonormalized()
	if not following_player and not heading_home:
		if not anims.get(bird_ind).is_playing():
			idle()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if discovered and body is Grabbable and not holding_note:
		var obj = body as Grabbable
		holding_note = obj
		
		if obj.active_tween:
			obj.active_tween.kill()
		if obj.mesh:
			obj.mesh.scale = obj.start_scale
			obj.mesh.position = Vector3.ZERO
		
		obj.global_position = marker.global_position
		obj.linear_velocity = Vector3.ZERO
		obj.angular_velocity = Vector3.ZERO
		obj.rotation = Vector3.ZERO
		obj.freeze = true
		obj.grabbed = false
		return_to_base()

#func _on_area_3d_body_exited(body: Node3D) -> void:
	#if discovered and body is Grabbable and holding_note:
		#var obj = body as Grabbable
		#if obj == holding_note:
			#holding_note = null

func go_to_player():
	heading_home = false
	following_player = true
	fly()
	if active_tween: active_tween.kill()
	var distance = (global_position - player.bird_marker.global_position).length()
	active_tween = create_tween()
	active_tween.tween_property(self, "global_position", player.bird_marker.global_position, 0.1*distance)

func return_to_base():
	if following_player:
		player.has_bird_following = false
	heading_home = true
	following_player = false
	fly()
	if active_tween: active_tween.kill()
	var distance = (global_position - gazebo.drop_off_marker.global_position).length()
	if holding_note:
		look_at(gazebo.drop_off_marker.global_position, Vector3.UP)
		active_tween = create_tween()
		active_tween.tween_property(self, "global_position", gazebo.drop_off_marker.global_position, 0.2*distance)
		active_tween.tween_callback(func():
			if holding_note:
				holding_note.freeze = false
				holding_note.linear_velocity = Vector3.ZERO
				holding_note.angular_velocity = Vector3.ZERO
				holding_note = null
			look_at(gazebo.markers[found_bird_num].global_position, Vector3.UP)
		)
		active_tween.tween_property(self, "global_position", gazebo.markers[found_bird_num].global_position, 1.0)
		await active_tween.finished
	else:
		look_at(gazebo.markers[found_bird_num].global_position, Vector3.UP)
		active_tween = create_tween()
		active_tween.tween_property(self, "global_position", gazebo.markers[found_bird_num].global_position, 0.3*distance)
		await active_tween.finished
	idle()
	heading_home = false

func enable_heart():
	heart.visible = true

func disable_heart():
	heart.visible = false

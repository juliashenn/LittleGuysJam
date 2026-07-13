extends Node3D
class_name Bird

@onready var interactable: Interactable = $Area3D
@onready var marker: Marker3D = $Marker3D

@export var bird_ind: int
@export var birds: Array[Node3D] = []
@export var anims: Array[AnimationPlayer] = []
var anim_prefix: String = ""
var found_bird_num: int
var holding_note: Grabbable
var discovered: bool = false

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = on_interact
	set_bird(randi() % birds.size())
	
func on_interact():
	discovered = true
	var player = get_tree().get_first_node_in_group("player") as Player
	found_bird_num = player.found_birds.size()
	player.found_birds.append(self)
	interactable.is_interactable = false

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

func _process(delta: float) -> void:
	if holding_note and not holding_note.grabbed:
		holding_note.global_position = marker.global_position
		holding_note.rotation = Vector3.ZERO

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

func _on_area_3d_body_exited(body: Node3D) -> void:
	if discovered and body is Grabbable and holding_note:
		var obj = body as Grabbable
		if obj == holding_note:
			holding_note = null

func go_to_player():
	pass
	# fly from base to player

func return_to_base():
	pass
	# fly from player to drop off, lower, drop, rest 

func _on_ground_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("ground"):
		if holding_note:
			holding_note.freeze = false
			holding_note = null

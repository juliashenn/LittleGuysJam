extends Camera3D
@onready var crosshair: MeshInstance3D = $Crosshair
@onready var wand: Wand = $wand
@export var player: Player

var ray_range = 10.0
var holding_cast = false

var grabbed_obj: Grabbable

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if holding_cast:
		var target = Get_Camera_Collision()
		if target:
			var local_target = to_local(target.get("position"))
			local_target.x = clamp(local_target.x,  -5.0, 5.0)
			local_target.y = clamp(local_target.y, -5.0, 5.0)
			local_target.z = clamp(local_target.z, -wand.max_length, -0.5)
			wand.set_target(to_global(local_target))
		else:
			wand.set_target(to_global(Vector3(0,0,-10)))
		

func _input(event):
	if event.is_action_pressed("poke"):
		var hit = Get_Camera_Collision()
		if hit:
			handle_poke(hit.collider)
	if event.is_action_released("cast"):
		holding_cast = false
		wand.set_is_casting(false)
		if grabbed_obj:
			grabbed_obj.drop()
			grabbed_obj = null
	if event.is_action_pressed("cast"):
		holding_cast = true
		wand.set_is_casting(true)
		var hit = Get_Camera_Collision()
		if hit:
			handle_grab(hit.collider)
		
func Get_Camera_Collision():
	var center = get_viewport().get_size()/2
	var ray_origin = project_ray_origin(center)
	var ray_end = ray_origin - global_basis.z * ray_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	new_intersection.collide_with_bodies = true
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	#if not intersection.is_empty():
		#print(intersection.collider.is_in_group("grabbable"))
		#print(intersection.collider.name)
	#else:
		#print("Nothing")
		
	return intersection
	
	
func handle_grab(collider: Node3D):
	if collider is Grabbable and grabbed_obj == null:
		grabbed_obj = collider as Grabbable
		grabbed_obj.grab()	
	
func handle_poke(collider: Node3D):
	if collider is Grabbable:
		if player:
			player.poke_anim()
		grabbed_obj = collider as Grabbable
		grabbed_obj.poke()

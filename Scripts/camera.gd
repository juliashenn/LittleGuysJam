extends Camera3D

@onready var wand: Wand = $wand
var ray_range = 2000.0
var holding_cast = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if holding_cast:
		var target = Get_Camera_Collision()
		if target:
			wand.set_target(target.position)
		else:
			wand.set_target(project_ray_origin(get_viewport().get_visible_rect().size / 2) \
			+ project_ray_normal(get_viewport().get_visible_rect().size / 2) * wand.max_length)
		

func _input(event):
	if event.is_action_pressed("poke"):
		Get_Camera_Collision()
	if event.is_action_released("cast"):
		holding_cast = false
		wand.set_is_casting(false)
	if event.is_action_pressed("cast"):
		holding_cast = true
		wand.set_is_casting(true)
		
func Get_Camera_Collision():
	var center = get_viewport().get_size()/2
	var ray_origin = project_ray_origin(center)
	var ray_end = ray_origin + project_ray_normal(center) * ray_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		print(intersection.collider.is_in_group("grabbable"))
		print(intersection.collider.name)
	else:
		print("Nothing")
		
	return intersection
	

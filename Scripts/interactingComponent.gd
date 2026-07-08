extends Node3D
#attach to player
@export var interact_label: Label

var current_interactions := []
var can_interact := true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			await current_interactions[0].interact.call()
			can_interact = true

func _on_area_entered(area: Area3D) -> void:
	if area is Interactable:
		current_interactions.push_back(area)

func _on_area_exited(area: Area3D) -> void:
	if area is Interactable:
		current_interactions.erase(area)

func _process(delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable :
			if current_interactions[0].interact_name and interact_label:
				interact_label.text = "[E] " + current_interactions[0].interact_name
				interact_label.show()
	elif interact_label:
		interact_label.hide() 

func _sort_by_nearest(area1, area2):
	var area1dist = global_position.distance_to(area1.global_position)
	var area2dist = global_position.distance_to(area2.global_position)
	return area1dist < area2dist

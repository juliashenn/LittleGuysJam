extends Node3D
class_name Stump

@export var holding_note: Grabbable
@onready var marker: Marker3D = $Marker3D
#@onready var light: OmniLight3D = $light
@export var defaultLight: Color
@export var correct: Color
@export var incorrect: Color
@onready var light: SpotLight3D = $SpotLight3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if holding_note and not holding_note.grabbed:
		holding_note.global_position = marker.global_position
		holding_note.rotation = Vector3.ZERO

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Grabbable and not holding_note:
		var obj = body as Grabbable
		obj.drop()
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
		light.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Grabbable and holding_note:
		var obj = body as Grabbable
		if obj == holding_note:
			holding_note = null
			light.hide()

func default_light():
	if defaultLight:
		light.light_color = defaultLight

func correct_light():
	if correct:
		light.light_color = correct

func incorrect_light():
	if incorrect:
		light.light_color = incorrect

extends Node3D
class_name Instrument

@export var anim: AnimationPlayer
@export var particles: CPUParticles3D
@export var audio: AudioStreamPlayer3D
@onready var light: SpotLight3D = $SpotLight3D

var awakened := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func awake():
	anim.play("awake")
	awakened = true

func play():
	light.visible = true
	if awakened:
		audio.play(0.0)
	start_particles()
	anim.play("playing")

func stop_playing():
	stop_particles()
	anim.stop()
	
func start_particles():
	particles.emitting = true

func stop_particles():
	particles.emitting = false
	

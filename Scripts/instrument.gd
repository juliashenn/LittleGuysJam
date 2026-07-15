extends Node3D
class_name Instrument

@export var anim: AnimationPlayer
@export var particles: CPUParticles3D
@export var audio: AudioStreamPlayer3D
@onready var light: SpotLight3D = $SpotLight3D

func _ready() -> void:
	light.visible = false


func awake():
	anim.play("awake")

func play():
	light.visible = true
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
	
func sleep():
	anim.play("RESET")
	stop_particles()

func start_play_anim():
	light.visible = true
	anim.play("playing")
	start_particles()

extends Node3D

@onready var interactable: Interactable = $Interactable
var player: Player
@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _on_interact():
	interactable.is_interactable = false
	anim.play("rise")
	player.give_dialogue(["...", "I'm just a little mushroom"])

func start_particle():
	particles.emitting = true

func stop_particle():
	particles.emitting = false

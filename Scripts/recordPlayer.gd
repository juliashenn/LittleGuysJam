extends Node3D
class_name RecordPlayer

@onready var audiostream: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var melody: Melody

@onready var playInteractable: Area3D = $Interactable
@onready var stopInteractable: Interactable = $Interactable2
var first_time := true
var player: Player
func _ready() -> void:
	audiostream.stream = load(melody.audioFile)
	playInteractable.is_interactable = true
	playInteractable.interact = _on_interact_play
	
	stopInteractable.is_interactable = false
	stopInteractable.interact = _on_interact_stop
	player = get_tree().get_first_node_in_group("player") as Player

func _process(delta: float) -> void:
	if not audiostream.playing and stopInteractable.is_interactable:
		stopInteractable.is_interactable = false
		playInteractable.is_interactable = true

func _on_interact_play():
	if playInteractable.is_interactable:
		audiostream.play(0.0)
		stopInteractable.is_interactable = true
		playInteractable.is_interactable = false
		if first_time:
			first_time = false
			player.give_dialogue(["Awaken the Raincloud to summon little notes"])

func _on_interact_stop():
	if stopInteractable.is_interactable:
		audiostream.stop()
		stopInteractable.is_interactable = false
		playInteractable.is_interactable = true

func stop():
	audiostream.stop()
	
func set_melody(m: Melody):
	if m:
		melody = m
		audiostream.stream = load(m.audioFile)

extends Node3D

@onready var audiostream: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var melody: Melody

@onready var interactable: Area3D = $Interactable

func _ready() -> void:
	melody = preload("res://Resources/tutorial.tres")
	audiostream.stream = load(melody.audioFile)
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _process(delta: float) -> void:
	pass

func _on_interact():
	if interactable.is_interactable:
		audiostream.play(0.0)

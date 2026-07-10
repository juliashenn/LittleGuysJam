extends Node3D

var melodyList := [preload("res://Resources/tutorial.tres"),
	preload("res://Resources/quarter.tres"),
	preload("res://Resources/half.tres"),
	preload("res://Resources/eighth.tres"),
	preload("res://Resources/mixed.tres")]

@onready var stump_spawner: Node3D = $StumpSpawner
@onready var water_spawner: Node3D = $Cloud


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

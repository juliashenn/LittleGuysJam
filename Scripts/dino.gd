extends Node3D

@onready var interactable: Interactable = $Interactable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = _on_interact()

func _on_interact():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

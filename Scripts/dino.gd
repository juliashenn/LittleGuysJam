extends Node3D

@onready var interactable: Interactable = $Interactable
var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _on_interact():
	interactable.is_interactable = false
	player.give_dialogue(["Rawr", "why are you taking all the mushrooms?"])

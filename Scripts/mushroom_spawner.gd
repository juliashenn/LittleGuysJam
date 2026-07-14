extends Spawner
@onready var interactable: Interactable = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = light_fire

func light_fire():
	interactable.is_interactable = false
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	player.spell_anim()
	await get_tree().create_timer(1.5).timeout
	spawn()

func reset():
	clear()
	interactable.is_interactable = true

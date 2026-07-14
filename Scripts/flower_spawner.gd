extends Spawner

@onready var interactable: Interactable = $Area3D

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = awaken

func awaken():
	interactable.is_interactable = false
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	player.spell_anim()
	await get_tree().create_timer(1.5).timeout
	spawn()

func reset():
	interactable.is_interactable = true
	clear()

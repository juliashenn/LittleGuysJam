extends Spawner

@onready var interactable: Interactable = $Area3D
@onready var gekko_interactable: Interactable = $gekko/Interactable
var player: Player

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = awaken
	
	gekko_interactable.is_interactable = true
	gekko_interactable.interact = gekko
	player = get_tree().get_first_node_in_group("player") as Player

func awaken():
	interactable.is_interactable = false
	
	player.spell_anim()
	await get_tree().create_timer(1.5).timeout
	spawn()

func reset():
	interactable.is_interactable = true
	clear()

func gekko():
	gekko_interactable.is_interactable = false
	player.give_dialogue(["Just keep swimming", "just keep swimming"])

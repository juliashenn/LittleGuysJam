extends Spawner

@onready var interactable: Interactable = $Area3D
var first_time := true
var player: Player

func _ready() -> void:
	interactable.is_interactable = true
	interactable.interact = awaken
	player = get_tree().get_first_node_in_group("player") as Player
	
func awaken():
	interactable.is_interactable = false
	player.spell_anim()
	await get_tree().create_timer(1.5).timeout
	spawn()
	if first_time:
		first_time = false
		await get_tree().create_timer(1.0).timeout
		player.give_dialogue(["Place the little guys on the tree stumps in the order you heard them",
		"left click to hear a little guy's note",
		"hold right to grab and move them",
		"lost a little guy? press esc to restart the note spawners"])
		
func reset():
	interactable.is_interactable = true
	clear()

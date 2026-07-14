extends Spawner
@onready var interactable: Interactable = $Area3D
@onready var fire_mesh: MeshInstance3D = $"forestEdit/Sketchfab_model/5e02c9e22c09485883e55c6d5bf1bded_fbx/RootNode/VFX_Mesh/VFX_Mesh_VFX_Material_0"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_mesh.visible = false
	interactable.is_interactable = true
	interactable.interact = light_fire

func light_fire():
	interactable.is_interactable = false
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	player.spell_anim()
	await get_tree().create_timer(1.5).timeout
	fire_mesh.visible = true
	spawn()

func reset():
	clear()
	interactable.is_interactable = true
	fire_mesh.visible = false

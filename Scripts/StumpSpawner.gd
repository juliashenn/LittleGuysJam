extends Node3D

@export var melody: Melody
@export var stump: PackedScene
@export var manager: Manager
@export var player: Player

@export var arc_ang = deg_to_rad(160.0)
@export var spacing = 1
@export var min_radius = 3.0
@onready var interactable: Interactable = $Area3D


var spawned_stumps : Array[Stump] = []
var noteToSec = {
	"Q": 0.857, "H": 1.714, "E": 0.4285
}
func _ready() -> void:
	#spawn()
	interactable.is_interactable = true
	interactable.interact = _on_interact

func _on_interact():
	check_solution()

func spawn():
	var count = melody.notes.size()
	if count == 0:
		return 
	
	var radius = max(min_radius, ((count - 1) * spacing) / arc_ang)
	
	var start_ang = -arc_ang / 2
	for i in count:
		var t = float(i) / (count - 1)
		var ang = lerp(start_ang, arc_ang / 2.0, t)
		var stump_obj = stump.instantiate() as Stump
		spawned_stumps.append(stump_obj)
		
		stump_obj.position = Vector3(cos(ang), 0, sin(ang)) * radius
		stump_obj.rotation.y = ang 
		add_child(stump_obj)
		
func check_solution():
	if not melody:
		return
	var count = melody.notes.size()
	player.conduct_anim()
	for i in count:
		var obj = spawned_stumps[i].holding_note
		if obj:
			var note: Note = obj.note
			if note == melody.notes[i]:
				obj.bounce()
				spawned_stumps[i].correct_light()
				await get_tree().create_timer(noteToSec.get(note.Length)).timeout
			else:
				spawned_stumps[i].incorrect_light()
				obj.poke() # failed
				await get_tree().create_timer(2.0).timeout
				failed()
				return
		else:
			failed()
			return
	solved()
	
func failed():
	player.stop_anim()
	for st in spawned_stumps:
		st.default_light()

func solved():
	player.stop_anim()
	await get_tree().create_timer(0.5).timeout
	manager.melody_solved()
	
func clear():
	for x in spawned_stumps:
		x.queue_free()
	spawned_stumps = []

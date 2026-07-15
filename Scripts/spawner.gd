extends Node3D
class_name Spawner

@export var radius = 5.0
@export var spacing = 1.0
@export var melody: Melody
@export var objToSpawn: PackedScene
@export var noteType: String

var spawned_objs: Array[Grabbable] = []

func spawn():
	var selected_notes = melody.notes.filter(func(note: Note):
		return note.Length == noteType)
	selected_notes += get_random_notes(melody.notes.size()/2)
	var count = selected_notes.size()
	if count == 0:
		return 
	var points = PoissonDiscSampling.generate_points_for_circle(
		Vector2.ZERO,
	 	radius, 
		spacing, 
		30) as Array[Vector2]
	points.shuffle()
	selected_notes.shuffle()
	var selected_points = points.slice(0, min(count, points.size()))
	#print("spawning " + noteType )
	for i in count:
		#print(selected_notes[i].fileName)
		var spawned_obj = objToSpawn.instantiate() as Grabbable
		spawned_objs.append(spawned_obj)
		spawned_obj.set_note(selected_notes[i])
		spawned_obj.position = Vector3(selected_points[i].x, global_position.y + randf(), selected_points[i].y)
		#water_obj.look_at_from_position(Vector3(selected_points[i].x, global_position.y, selected_points[i].y), Vector3.ZERO, Vector3.UP)
		add_child(spawned_obj)
		await get_tree().create_timer(randf()).timeout

func get_all_notes() -> Array[Note]:
	match noteType:
		"Q":
			return NoteDatabase.quarter_notes.duplicate()
		"H":
			return NoteDatabase.half_notes.duplicate()
		"E":
			return NoteDatabase.eighth_notes.duplicate()
	return []
	
func get_random_notes(n: int) -> Array[Note]:
	var all = get_all_notes()
	all.shuffle()
	return all.slice(0, min(n, all.size()))

func clear():
	for x in spawned_objs:
		x.queue_free()
	spawned_objs = []

func reset():
	clear()

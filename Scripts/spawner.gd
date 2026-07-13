extends Node3D
class_name Spawner

@export var radius = 5.0
@export var spacing = 1.0
@export var melody: Melody
@export var objToSpawn: PackedScene
@export var noteType: String


var spawned_objs: Array[Grabbable] = []

func _ready() -> void:
	#spawn()
	pass

	
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

func get_all_notes() -> Array[Note]:
	var result: Array[Note] = []
	var folder
	match noteType:
		"Q":
			folder = "QuarterNotes"
		"H":
			folder = "HalfNotes"
		"E":
			folder = "EighthNotes"
	var dir = DirAccess.open("res://Resources/" + folder + "/")
	for file in dir.get_files():
		if file.ends_with(".tres") or file.ends_with(".res"):
			var note = load("res://Resources/" + folder + "/" + file) as Note
			if note:
				note.fileName = file.get_basename()
				if note.Length == noteType:
					result.append(note)
	return result
	
func get_random_notes(n: int) -> Array[Note]:
	var all = get_all_notes()
	all.shuffle()
	return all.slice(0, n)

func clear():
	for x in spawned_objs:
		x.queue_free()
	spawned_objs = []

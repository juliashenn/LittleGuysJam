extends Node3D
@export var radius = 5.0
@export var spacing = 1.0
@export var melody: Melody
@export var water: PackedScene

var spawned_water: Array[Grabbable] = []

func _ready() -> void:
	spawn()

	
func spawn():
	var quarter_notes = melody.notes.filter(func(note: Note):
		return note.Length == "Q")
	quarter_notes += get_random_notes(melody.notes.size()/2)
	var count = quarter_notes.size()
	if count == 0:
		return 
	var points = PoissonDiscSampling.generate_points_for_circle(
		Vector2.ZERO,
	 	radius, 
		spacing, 
		30) as Array[Vector2]
	points.shuffle()
	var selected_points = points.slice(0, min(count, points.size()))
	print("Notes to spawn: ", quarter_notes.size())
	for i in count:
		print(i, " -> ", quarter_notes[i].fileName if quarter_notes[i] else "NULL")
		var water_obj = water.instantiate() as Grabbable
		spawned_water.append(water_obj)
		water_obj.set_note(quarter_notes[i])
		water_obj.position = Vector3(selected_points[i].x, global_position.y, selected_points[i].y)
		#water_obj.look_at_from_position(Vector3(selected_points[i].x, global_position.y, selected_points[i].y), Vector3.ZERO, Vector3.UP)
	
		add_child(water_obj)

func get_all_quarter_notes() -> Array[Note]:
	var result: Array[Note] = []
	var dir = DirAccess.open("res://Resources/QuarterNotes/")
	for file in dir.get_files():
		if file.ends_with(".tres") or file.ends_with(".res"):
			var note = load("res://Resources/QuarterNotes/" + file) as Note
			if note:
				note.fileName = file.get_basename()
				if note.Length == "Q":
					result.append(note)
	return result
	
func get_random_notes(n: int) -> Array[Note]:
	var all = get_all_quarter_notes()
	all.shuffle()
	return all.slice(0, n)

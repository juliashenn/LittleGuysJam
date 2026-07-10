extends Resource
class_name Melody

@export var notes: Array[Note] = []
var fileName: String: 
	get: 
		return resource_path.get_basename().get_file()
var audioFile: String:
	get:
		return "res://Sound/" + fileName + ".wav"

var quarternotes: Array[Note]:
	get:
		return notes.filter(func(note: Note): return note.Length == "Q")

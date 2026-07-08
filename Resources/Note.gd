extends Resource
class_name Note


var fileName: String: 
	get: 
		return resource_path.get_basename().get_file()
var Pitch: String:
	get:
		return fileName.substr(0, fileName.length() - 2)
var Length: String:
	get:
		return fileName.substr(fileName.length() - 1, fileName.length())
var audioFile: String:
	get:
		return "res://Sound/Notes/" + fileName + ".wav"

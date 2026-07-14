extends Node3D
class_name Gazebo

@onready var marker_parent: Node3D = $markers
var markers : Array[Node] = []
@onready var drop_off_marker: Marker3D = $dropOff

func _ready() -> void:
	markers = marker_parent.get_children()

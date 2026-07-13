extends Node3D

@export var bird_ind: int
@export var birds: Array[Node3D] = []
@export var anims: Array[AnimationPlayer] = []
var anim_prefix: String = ""

func _ready() -> void:
	pass # Replace with function body.

func set_bird(i: int):
	bird_ind = i
	for x in range(birds.size()):
		if x == i:
			birds.get(x).visibile = true
			var name = birds.get(x).name
			anim_prefix = name+"|"+name+"|"+name+"|"
		else:
			birds.get(x).visibile = false

func fly():
	anims.get(bird_ind).play(anim_prefix+"fly")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

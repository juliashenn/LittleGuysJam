extends Node3D
class_name Manager

var melodyList := [preload("res://Resources/tutorial.tres"),
	preload("res://Resources/quarter.tres"),
	preload("res://Resources/half.tres"),
	preload("res://Resources/eighth.tres"),
	preload("res://Resources/mixed.tres")]
var curr_level = 0
var curr_melody: Melody

@onready var recorder: RecordPlayer = $Recorder
@onready var stump_spawner: Node3D = $StumpSpawner
@onready var water_spawner: Spawner = $Cloud
@onready var mushroom_spawner: Spawner = $MushroomSpawner
@onready var flower_spawner: Spawner = $FlowerSpawner
@onready var cutscene_player: AnimationPlayer = $AnimationPlayer
@onready var ui: UI = $CharacterBody3D/UI
@onready var cutscene_anim: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $CharacterBody3D

@onready var final_audio: AudioStreamPlayer3D = $Camera3D/AudioStreamPlayer3D

func start():
	player.blink()
	cutscene_anim.play("intro")
	set_up_melody()
	await cutscene_anim.animation_finished
	await get_tree().create_timer(0.5).timeout
	player.give_dialogue(["Interact with the Record Player to hear the first melody"])

func set_up_melody():
	curr_melody = melodyList.get(curr_level)
	recorder.set_melody(curr_melody)
	stump_spawner.melody = curr_melody
	water_spawner.melody = curr_melody
	mushroom_spawner.melody = curr_melody
	flower_spawner.melody = curr_melody
	stump_spawner.spawn()
	#spawn()

func melody_solved():
	if curr_level != 0: 
		cutscene_anim.play(str(curr_level))
	player.blink()
	curr_level += 1
	if curr_level == 5:
		cutscene_anim.play("final")
		return
	#clear_spawner()
	stump_spawner.clear()
	reset_spawners()
	set_up_melody()
	
func clear_spawner():
	water_spawner.clear()
	mushroom_spawner.clear()
	flower_spawner.clear()
	stump_spawner.clear()

func reset_spawners():
	water_spawner.reset()
	mushroom_spawner.reset()
	flower_spawner.reset()

func spawn():
	# each spawner should have their own trigger but for now
	stump_spawner.spawn()
	water_spawner.spawn()
	flower_spawner.spawn()
	mushroom_spawner.spawn()

func play_final():
	final_audio.play(0.0)

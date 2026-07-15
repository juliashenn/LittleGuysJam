extends Control
class_name UI

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var black: ColorRect = $black
@onready var interact_label: Label = $VBoxContainer/InteractLabel

#dialogue
@onready var dialogue: Control = $dialogue
@onready var label: RichTextLabel = $dialogue/label
var dialogue_lines: Array[String] = []
var current_line := 0
var full_text: String = ""
var current_text: String = ""
var char_index := 0
var is_typing := false
@export var typing_speed := 0.1

# settings
@export var player: Player
@export var manager: Manager
@onready var settings: Control = $Settings
@onready var h_slider: HSlider = $Settings/HBoxContainer/left/Volume/HSlider
@onready var test_audio: AudioStreamPlayer3D = $Settings/AudioStreamPlayer3D
@onready var credit: Control = $credits
@onready var start: Control = $Start
@onready var start_song: AudioStreamPlayer3D = $Start/startSong
@onready var end: Control = $end
var ending := false
@onready var esc: Label = $esc
@onready var progress_text: RichTextLabel = $dialogue/instruction/progress

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	fadeFromBlack()
	start.visible = true
	credit.visible = false
	settings.visible = false
	dialogue.visible = false
	#await get_tree().create_timer(0.5).timeout
	#player.freeze()
	#show_dialogue("hihi")
	#credits()
	
func credits():
	start_song.stop()
	ending = true
	esc.visible = false
	credit.visible = true
	dialogue.visible = false
	interact_label.visible = false
	anim.play("credits")

func fadeToBlack():
	black.visible = true
	anim.play("fadeToBlack")
	await anim.animation_finished
	
func fadeFromBlack():
	anim.play_backwards("fadeToBlack")
	await anim.animation_finished
	black.visible = false
	
func show_dialogue(strs: Array[String]):
	if dialogue.visible:
		dialogue_lines += strs
		progress_text.text = str(current_line + 1) + "/" + str(dialogue_lines.size())
		return
	#player.freeze()
	#player.enabled = false
	dialogue.visible = true
	dialogue_lines = strs
	current_line = 0
	start_line(strs[0])

func start_line(str: String):
	full_text = str
	current_text = ""
	char_index = 0
	is_typing = true
	label.text = ""
	set_process(true)
	progress_text.text = str(current_line + 1) + "/" + str(dialogue_lines.size())

#func type_line():
	#while char_index < full_text.length():
		#if not is_typing:
			#break
		#current_text += full_text[char_index]
		#label.text = current_text
		#char_index += 1
		#await get_tree().create_timer(typing_speed).timeout
	#label.text = full_text  # ensure full text always shows at end
	#is_typing = false
	
func _process(delta):
	if not is_typing:
		return
	if char_index < full_text.length():
		current_text += full_text[char_index]
		label.text = current_text
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	else:
		is_typing = false
		
func _unhandled_input(event: InputEvent):
	if not dialogue.visible:
		return
	if event.is_action_pressed("accept"):
		get_viewport().set_input_as_handled()  # stop it reaching player/camera
		advance()

func advance():
	if is_typing:
		label.text = full_text
		is_typing = false
		return
	current_line += 1
	if current_line < dialogue_lines.size():
		start_line(dialogue_lines[current_line])
	else:
		hide_dialogue()

func hide_dialogue():
	#if not settings.visible:
		#player.unfreeze()
	dialogue.visible = false
	label.text = ""

func show_settings():
	if ending:
		return
	player.freeze()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	settings.visible = true


func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(h_slider.value))
	test_audio.play(0.0)


func _on_close_pressed() -> void:
	player.unfreeze()
	settings.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_end():
	player.freeze()
	end.visible = true

func _on_skip_pressed() -> void:
	show_end()

var intro_lines : Array[String] = [
	"The magical instruments have fallen into a deep slumber",
	"Only their favorite melodies can awaken them",
	"Restore each melody with the help of little note sprites",
	"And let the orchestra play together once more"
]
func intro():
	show_dialogue(intro_lines)

func _on_start_pressed() -> void:
	start.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	manager.start()
	await manager.cutscene_anim.animation_finished
	var tween = create_tween()
	tween.tween_property(start_song, "volume_db", -75, 2.0)
	await tween.finished
	start_song.stop()

func _on_reset_water_pressed() -> void:
	manager.water_spawner.reset()
	player.unfreeze()
	settings.visible = false
	player.give_dialogue(["water drops have returned to their slumber"])

func _on_reset_flower() -> void:
	if manager.curr_level > 1:
		manager.flower_spawner.reset()
		player.unfreeze()
		settings.visible = false
		player.give_dialogue(["flowers have returned to their slumber"])

func _on_reset_mushroom() -> void:
	if manager.curr_level > 2:
		manager.mushroom_spawner.reset()
		player.unfreeze()
		settings.visible = false
		player.give_dialogue(["mushrooms have returned to their slumber"])


func _on_skip_to_end_pressed() -> void:
	settings.visible = false
	manager.cutscene_anim.play("final")

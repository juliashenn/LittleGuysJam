extends Control
class_name UI

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var black: ColorRect = $black

#dialogue
@onready var dialogue: Control = $dialogue
@onready var label: RichTextLabel = $dialogue/label
var dialogue_lines: Array[String] = []
var current_line := 0
var full_text: String = ""
var current_text: String = ""
var char_index := 0
var is_typing := false
@onready var typing_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var typing_speed := 0.1

# settings
@export var player: Player
@export var manager: Manager
@onready var settings: Control = $Settings
@onready var h_slider: HSlider = $Settings/HBoxContainer/left/Volume/HSlider
@onready var test_audio: AudioStreamPlayer3D = $Settings/AudioStreamPlayer3D
@onready var credit: Control = $credits
@onready var start: Control = $Start
@onready var end: Control = $end
var ending := false
@onready var esc: Label = $esc

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	fadeFromBlack()
	start.visible = true
	credit.visible = false
	settings.visible = false
	#await get_tree().create_timer(0.5).timeout
	#player.freeze()
	#show_dialogue("hihi")
	#credits()
	
func credits():
	ending = true
	esc.visible = false
	credit.visible = true
	anim.play("credits")

func fadeToBlack():
	black.visible = true
	print("fading to")
	anim.play("fadeToBlack")
	await anim.animation_finished
	
func fadeFromBlack():
	anim.play_backwards("fadeToBlack")
	await anim.animation_finished
	black.visible = false
	
func show_dialogue(strs: Array[String]):
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
	typing_audio.play(0.0)

func _process(delta):
	if not is_typing:
		return
	if char_index < full_text.length():
		if not typing_audio.playing:
			typing_audio.play(0.0)
		current_text += full_text[char_index]
		label.text = current_text
		char_index += 1
		await get_tree().create_timer(typing_speed).timeout
	else:
		typing_audio.stop()
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
		typing_audio.stop()
		hide_dialogue()

func hide_dialogue():
	#if not settings.visible:
		#player.unfreeze()
	typing_audio.stop()
	dialogue.visible = false
	label.text = ""

func show_settings():
	if ending:
		return
	player.freeze()
	settings.visible = true


func _on_h_slider_value_changed(value: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(h_slider.value))
	test_audio.play(0.0)


func _on_close_pressed() -> void:
	if not dialogue.visible:
		player.unfreeze()
	settings.visible = false

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
	manager.start()

func _on_reset_spawners_pressed() -> void:
	manager.reset_spawners()
	if not dialogue.visible:
		player.unfreeze()
	settings.visible = false
	show_dialogue(["Spawners have been reset"])

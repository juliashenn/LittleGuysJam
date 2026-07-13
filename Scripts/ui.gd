extends Control
class_name UI

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var black: ColorRect = $black

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fadeFromBlack()
	await get_tree().create_timer(0.5).timeout
	credits()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func credits():
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

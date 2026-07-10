extends Grabbable

@export var animator: AnimationPlayer
@export var animName: String
@export var sectionStart: float
@export var sectionEnd: float

func bounce():
	audio.play(0.0)
	if animator and not animName.is_empty():
		animator.play_section(animName, sectionStart, sectionEnd)
		await animator.animation_finished
		animator.speed_scale *= 1.5
		animator.play_section_backwards(animName, sectionStart, sectionEnd)
		await animator.animation_finished
		animator.speed_scale /= 1.5

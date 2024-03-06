class_name AudioBus
extends Node


@onready var button_hover_sfx: AudioStreamPlayer = $ButtonHoverSFX
@onready var button_press_sfx: AudioStreamPlayer = $ButtonPressSFX


func play_button_selected() -> void:
	button_press_sfx.play()


func play_button_hovered() -> void:
	if not button_press_sfx.playing:
		button_hover_sfx.play()


func _modulate_pitch(audio_player: AudioStreamPlayer2D) -> void:
	audio_player.pitch_scale = randf_range(0.95, 1.05)

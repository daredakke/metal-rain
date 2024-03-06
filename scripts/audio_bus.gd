class_name AudioBus
extends Node


@onready var button_hover_sfx: AudioStreamPlayer = $ButtonHoverSFX
@onready var button_press_sfx: AudioStreamPlayer = $ButtonPressSFX
@onready var missile_explosion_sfx: AudioStreamPlayer2D = $MissileExplosionSFX


func _ready() -> void:
	Global.missile_exploded.connect(_play_missile_exploded)


func play_button_pressed() -> void:
	button_press_sfx.play()


func play_button_hovered() -> void:
	if not button_press_sfx.playing:
		button_hover_sfx.play()


func _play_missile_exploded() -> void:
	missile_explosion_sfx.play()


func _on_missile_explosion_sfx_finished() -> void:
	_modulate_pitch(missile_explosion_sfx)


func _modulate_pitch(audio_player: AudioStreamPlayer2D) -> void:
	audio_player.pitch_scale = randf_range(0.93, 1.07)

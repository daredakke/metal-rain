class_name AudioBus
extends Node


@onready var button_hover_sfx: AudioStreamPlayer = $ButtonHoverSFX
@onready var button_press_sfx: AudioStreamPlayer = $ButtonPressSFX
@onready var missile_explosion_sfx: AudioStreamPlayer2D = $MissileExplosionSFX
@onready var player_shot_sfx: AudioStreamPlayer2D = $PlayerShotSFX
@onready var transition_message_sfx: AudioStreamPlayer = $TransitionMessageSFX
@onready var transition_level_sfx: AudioStreamPlayer = $TransitionLevelSFX
@onready var player_shot_explosion_sfx: AudioStreamPlayer2D = $PlayerShotExplosionSFX
@onready var game_music: AudioStreamPlayer = $GameMusic
@onready var menu_music: AudioStreamPlayer = $MenuMusic


func _ready() -> void:
	Global.missile_exploded.connect(_play_missile_exploded)
	Global.player_shot.connect(_play_player_shot)
	Global.player_shot_exploded.connect(_play_player_shot_exploded)
	Global.transition_message_shown.connect(_play_transition_message_shown)
	Global.transition_level_shown.connect(play_transition_level_shown)


func play_game_music() -> void:
	game_music.play()


func stop_game_music() -> void:
	game_music.stop()


func play_menu_music() -> void:
	menu_music.play()


func stop_menu_music() -> void:
	menu_music.stop()


func play_button_pressed() -> void:
	button_press_sfx.play()


func play_button_hovered() -> void:
	if not button_press_sfx.playing:
		button_hover_sfx.play()


func play_transition_level_shown() -> void:
	transition_level_sfx.play()


func _play_missile_exploded() -> void:
	missile_explosion_sfx.play()


func _play_player_shot() -> void:
	player_shot_sfx.play()


func _play_transition_message_shown() -> void:
	transition_message_sfx.play()


func _play_player_shot_exploded() -> void:
	player_shot_explosion_sfx.play()


func _on_missile_explosion_sfx_finished() -> void:
	_modulate_pitch(missile_explosion_sfx)


func _on_player_shot_sfx_finished() -> void:
	_modulate_pitch(player_shot_sfx)


func _on_player_shot_explosion_sfx_finished() -> void:
	_modulate_pitch(player_shot_explosion_sfx)


func _on_game_music_finished() -> void:
	play_game_music()


func _on_menu_music_finished() -> void:
	play_menu_music()


func _modulate_pitch(audio_player: AudioStreamPlayer2D) -> void:
	audio_player.pitch_scale = randf_range(0.93, 1.07)

extends Node


enum Mode {
	WINDOW_ONE,
	WINDOW_TWO,
	FULLSCREEN,
}

var game_started: bool = false
var game_paused: bool:
	set(new_value):
		game_paused = new_value
		get_tree().paused = game_paused
var resolutions: Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(1280, 720),
]


func pause_game() -> void:
	game_paused = true


func unpause_game() -> void:
	game_paused = false
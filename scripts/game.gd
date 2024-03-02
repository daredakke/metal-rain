class_name Game
extends Node2D


enum Mode {
	WINDOW_ONE,
	WINDOW_TWO,
	FULLSCREEN,
}

const SHAKE_SPEED: float = 30.0
const SHAKE_STRENGTH: float = 8.25
const SHAKE_DECAY_RATE: float = 10


var _game_paused: bool:
	set(new_value):
		_game_paused = new_value
		_handle_pause_state()
var _current_mode: int = Mode.WINDOW_ONE
var _resolutions: Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(1280, 720),
]
var _shake_speed: float:
	set(value):
		_shake_speed = clampf(value, 0.0, 100.0)
var _noise_i: float = 0.0
var _shake_strength: float = 0.0:
	set(value):
		_shake_strength = clampf(value, 0.0, 100.0)

@onready var camera: Camera2D = %Camera
@onready var pause: Control = %Pause
@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()


func _ready() -> void:
	rand.randomize()
	noise.seed = randi()
	noise.frequency = 0.5
	_game_paused = true
	
	_resize_screen(_current_mode)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test_shake"):
		_shake_screen(SHAKE_STRENGTH, SHAKE_SPEED)
	
	if Input.is_action_just_pressed("test_resize"):
		_current_mode += 1
		
		if _current_mode >= Mode.size():
			_current_mode = 0
		
		_resize_screen(_current_mode)
	
	camera.offset = _screen_shake_decay(delta, SHAKE_DECAY_RATE)


func _handle_pause_state() -> void:
	get_tree().paused = _game_paused
	
	if _game_paused:
		pause.show()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		#crosshair.hide()
	else:
		pause.hide()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
		#crosshair.show()


func _resize_screen(mode: int) -> void:
	match mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			ProjectSettings.set_setting("display/window/size/borderless", false)
			get_window().size = _resolutions[mode]
			get_window().move_to_center()
		1:
			get_window().size = _resolutions[mode]
			get_window().move_to_center()
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _shake_screen(strength: float, speed: float) -> void:
	_shake_strength = strength
	_shake_speed = speed


func _screen_shake_decay(delta: float, decay_rate: float) -> Vector2:
	_shake_strength = lerp(_shake_strength, 0.0, decay_rate * delta)
	_noise_i += delta * _shake_speed
	
	return Vector2(
		noise.get_noise_2d(1, _noise_i) * _shake_strength,
		noise.get_noise_2d(100, _noise_i) * _shake_strength
	)

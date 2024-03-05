class_name Game
extends Node2D


const SHAKE_DECAY_RATE: float = 10

var _current_mode: int = Global.Mode.WINDOW_ONE
var _shake_speed: float:
	set(value):
		_shake_speed = clampf(value, 0.0, 100.0)
var _noise_i: float = 0.0
var _shake_strength: float = 0.0:
	set(value):
		_shake_strength = clampf(value, 0.0, 100.0)
var _level: int = 1
var _ammo_restock_amount: int = 2

@onready var level_end_delay: Timer = %LevelEndDelay
@onready var camera: Camera2D = %Camera
@onready var pause: Control = %Pause
@onready var hud: Control = %HUD
@onready var game_over: GameOver = %GameOver
@onready var point_defence: PointDefence = %PointDefence
@onready var missile_spawner: MissileSpawner = %MissileSpawner
@onready var crosshair: Crosshair = %Crosshair
@onready var cities: Node2D = %Cities
@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()


func _ready() -> void:
	level_end_delay.timeout.connect(_next_level)
	pause.new_game_started.connect(_start_new_game)
	pause.game_exited.connect(_quit_game)
	pause.game_continued.connect(_unpause_game)
	pause.volume_changed.connect(_change_volume)
	pause.resolution_changed.connect(_resize_screen)
	point_defence.gun_fired.connect(_shake_screen)
	point_defence.ammo_changed.connect(hud.display_shot_indicators)
	missile_spawner.level_over.connect(_end_level)
	cities.all_cities_destroyed.connect(_game_over)
	
	_resize_screen(_current_mode)
	rand.randomize()
	noise.seed = randi()
	noise.frequency = 0.5
	_pause_game()
	crosshair.randomise_rotation()


func _process(delta: float) -> void:
	if not Global.game_started or Global.game_over:
		return
		
	if Input.is_action_just_pressed("pause") and not Global.game_paused:
		_pause_game()
	
	if Input.is_action_just_pressed("debug_destroy_city"):
		_debug_destroy_cities()
	
	# Don't process camera shake if game paused
	if Global.game_paused:
		return
	
	camera.offset = _screen_shake_decay(delta, SHAKE_DECAY_RATE)


func _start_new_game() -> void:
	Global.game_started = true
	_level = 1
	
	for city in cities.get_children():
		city.restore()
	
	missile_spawner.reset()
	point_defence.reset()
	_unpause_game()


func _debug_destroy_cities() -> void:
	for city in cities.get_children():
		city._hp = 0


func _pause_game() -> void:
	Global.pause_game()
	_handle_pause_state()


func _unpause_game() -> void:
	Global.unpause_game()
	_handle_pause_state()


func _end_level() -> void:
	_level += 1
	
	level_end_delay.start()


func _next_level() -> void:
	_ammo_restock_amount += 3 if _level % 3 == 0 else 0
	
	point_defence.restock_ammo(_ammo_restock_amount)
	
	missile_spawner.mirv_chance += 0.01
	missile_spawner.salvo_size += 1
	missile_spawner.missile_speed += 1.0
	missile_spawner.spawn_delay -= 0.005
	missile_spawner.start()


func _game_over() -> void:
	# Remove any screen shake
	camera.offset = Vector2.ZERO
	Global.game_over = true
	
	game_over.show()
	pause.continue_button.hide()
	_pause_game()


func _handle_pause_state() -> void:
	if Global.game_paused:
		pause.show()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		crosshair.hide()
	else:
		pause.hide()
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
		crosshair.show()


func _resize_screen(mode: int) -> void:
	match mode:
		Global.Mode.WINDOW_ONE, Global.Mode.WINDOW_TWO:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			ProjectSettings.set_setting("display/window/size/borderless", false)
			get_window().size = Global.resolutions[mode]
			get_window().move_to_center()
		
		Global.Mode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _change_volume(bus_index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(bus_index, value < 0.05)


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


func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

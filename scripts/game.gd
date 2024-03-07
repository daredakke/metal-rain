class_name Game
extends Node2D


const SHAKE_DECAY_RATE: float = 10
const INIT_AMMO_RESTOCK_AMOUNT: int = 2

var _level_transitioning: bool = false
var _shake_speed: float:
	set(value):
		_shake_speed = clampf(value, 0.0, 100.0)
var _noise_i: float = 0.0
var _shake_strength: float = 0.0:
	set(value):
		_shake_strength = clampf(value, 0.0, 100.0)
var _ammo_restock_amount: int = 2

@onready var audio_bus: AudioBus = %AudioBus
@onready var level_end_delay: Timer = %LevelEndDelay
@onready var camera: Camera2D = %Camera
@onready var pause: Control = %Pause
@onready var hud: Control = %HUD
@onready var level_transition: LevelTransition = %LevelTransition
@onready var game_over: GameOver = %GameOver
@onready var fade_out: FadeOut = %FadeOut
@onready var splash: Splash = $Camera/UI/Splash
@onready var point_defence: PointDefence = %PointDefence
@onready var missile_spawner: MissileSpawner = %MissileSpawner
@onready var film_grain_canvas: CanvasLayer = %FilmGrainCanvas
@onready var crosshair: Crosshair = %Crosshair
@onready var cities: Node2D = %Cities
@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()


func _enter_tree() -> void:
	get_tree().node_added.connect(_connect_button_sfx)


func _ready() -> void:
	level_end_delay.timeout.connect(_start_level_transition)
	pause.new_game_started.connect(_new_game_transition)
	pause.game_exited.connect(_quit_game)
	pause.game_continued.connect(_unpause_game)
	pause.volume_changed.connect(_change_volume)
	pause.resolution_changed.connect(_resize_screen)
	pause.film_grain_toggled.connect(_toggle_film_grain)
	level_transition.initial_transition_finished.connect(_start_new_game)
	level_transition.level_transitioned.connect(_next_level)
	point_defence.gun_fired.connect(_shake_screen)
	point_defence.gun_damaged.connect(_shake_screen)
	point_defence.gun_destroyed.connect(_shake_screen)
	point_defence.ammo_changed.connect(hud.display_shot_indicators)
	missile_spawner.level_over.connect(_end_level)
	cities.all_cities_destroyed.connect(_fade_out)
	cities.city_damaged.connect(_shake_screen)
	cities.city_destroyed.connect(_shake_screen)
	fade_out.fade_out_complete.connect(_game_over)
	splash.splash_ended.connect(_play_menu_music)
	
	noise.seed = randi()
	noise.frequency = 0.5
	
	pause.load_settings()
	#_resize_screen(_current_mode)
	rand.randomize()
	_pause_game()
	crosshair.randomise_rotation()


func _process(delta: float) -> void:
	if not Global.game_started:
		return
		
	if Input.is_action_just_pressed("pause") and not Global.game_paused and not _level_transitioning:
		_pause_game()
	
	# Don't process camera shake if game paused
	if Global.game_paused:
		return
	
	camera.offset = _screen_shake_decay(delta, SHAKE_DECAY_RATE)


func _connect_button_sfx(node: Node) -> void:
	if node is Button:
		node.mouse_entered.connect(_button_hovered)
		node.pressed.connect(_button_pressed)
	
	if node is HSlider:
		node.mouse_entered.connect(_button_hovered)
		
	if node.is_in_group("sfx_slider"):
		node.drag_ended.connect(_sfx_slider_drag_ended)


func _start_new_game() -> void:
	Global.game_started = true
	point_defence.can_fire = true

	audio_bus.play_game_music()
	missile_spawner.start()


func _new_game_transition() -> void:
	Global.missiles_shot_down = 0
	Global.level = 1
	_ammo_restock_amount = INIT_AMMO_RESTOCK_AMOUNT
	
	audio_bus.stop_menu_music()
	_unpause_game()
	
	for city in cities.get_children():
		city.restore()
	
	missile_spawner.reset()
	point_defence.reset()
	
	level_transition.shuffle_messages()
	_start_level_transition()


func _start_level_transition() -> void:
	point_defence.can_fire = false
	_level_transitioning = true
	level_transition.start(Global.level)


func _next_level() -> void:
	point_defence.can_fire = true
	_level_transitioning = false
	
	_ammo_restock_amount += 2 if Global.level % 3 == 0 else 0
	
	point_defence.restock_ammo(_ammo_restock_amount)
	
	missile_spawner.mirv_chance += 0.03
	missile_spawner.salvo_size += 1
	missile_spawner.missile_speed += 1.5
	missile_spawner.spawn_delay -= 0.02
	missile_spawner.start()


func _end_level() -> void:
	Global.level += 1
	
	level_end_delay.start()


func _fade_out() -> void:
	point_defence.can_fire = false
	missile_spawner.stop()
	audio_bus.stop_game_music()
	
	fade_out.start()


func _game_over() -> void:
	# Remove any screen shake
	camera.offset = Vector2.ZERO
	Global.game_started = false
	
	audio_bus.play_transition_level_shown()
	_play_menu_music()
	game_over.show()
	pause.continue_button.hide()
	_pause_game()


func _pause_game() -> void:
	Global.pause_game()
	_handle_pause_state()


func _unpause_game() -> void:
	Global.unpause_game()
	_handle_pause_state()


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


func _toggle_film_grain(state: bool) -> void:
	film_grain_canvas.visible = state


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


func _play_menu_music() -> void:
	audio_bus.play_menu_music()


func _button_hovered() -> void:
	audio_bus.play_button_hovered()


func _button_pressed() -> void:
	audio_bus.play_button_pressed()


func _sfx_slider_drag_ended(_value_changed: float) -> void:
	audio_bus.play_button_pressed()


func _quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

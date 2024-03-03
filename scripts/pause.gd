class_name Pause
extends Control


signal game_continued
signal new_game_started
signal game_exited
signal volume_changed(bus_index: int, value: float)
signal resolution_changed(mode: int)

var _delay_process: bool = true
var _music_bus: int = AudioServer.get_bus_index("Music")
var _sfx_bus: int = AudioServer.get_bus_index("SFX")

@onready var continue_button: Button = %ContinueButton
@onready var new_game_button: Button = %NewGameButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var settings_panel: Panel = %SettingsPanel
@onready var music_value_label: Label = %MusicValueLabel
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_value_label: Label = %SFXValueLabel
@onready var sfx_slider: HSlider = %SFXSlider
@onready var one_x_check_box: CheckBox = %OneXCheckBox
@onready var two_x_check_box: CheckBox = %TwoXCheckBox
@onready var fullscreen_check_box: CheckBox = %FullscreenCheckBox
@onready var settings_close_button: Button = %SettingsCloseButton


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	settings_close_button.pressed.connect(_on_settings_close_button_pressed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	one_x_check_box.pressed.connect(_on_one_x_check_box_pressed)
	two_x_check_box.pressed.connect(_on_two_x_check_box_pressed)
	fullscreen_check_box.pressed.connect(_on_fullscreen_check_box_pressed)
	
	continue_button.hide()
	settings_panel.hide()


func _process(_delta: float) -> void:
	# Ensure pause menu doesn't immediately unpause when pause button pressed
	if _delay_process:
		_delay_process = false
		return
	
	if Input.is_action_just_pressed("pause"):
		if settings_panel.visible:
			settings_panel.hide()
		else:
			if Global.game_started:
				_delay_process = true
				game_continued.emit()


func _on_new_game_button_pressed() -> void:
	continue_button.show()
	_delay_process = true
	new_game_started.emit()


func _on_continue_button_pressed() -> void:
	_delay_process = true
	game_continued.emit()


func _on_quit_button_pressed() -> void:
	game_exited.emit()


func _on_settings_button_pressed() -> void:
	settings_panel.show()


func _on_settings_close_button_pressed() -> void:
	settings_panel.hide()


func _on_music_slider_value_changed(value: float) -> void:
	music_value_label.text = str(floor(value * 100)) + "%"
	
	volume_changed.emit(_music_bus, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	sfx_value_label.text = str(floor(value * 100)) + "%"
	
	volume_changed.emit(_sfx_bus, value)


func _on_one_x_check_box_pressed() -> void:
	_resolution_changed(0)


func _on_two_x_check_box_pressed() -> void:
	_resolution_changed(1)


func _on_fullscreen_check_box_pressed() -> void:
	_resolution_changed(2)


func _resolution_changed(mode: int) -> void:
	resolution_changed.emit(mode)

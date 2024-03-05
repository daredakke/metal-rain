class_name Splash
extends Control


signal splash_ended

@export var bypass_splash: bool = false

@onready var boiling: AnimationPlayer = $Boiling
@onready var splash_timer: Timer = $splash_timer


func _ready() -> void:
	splash_timer.timeout.connect(_end_splash)
	show()
	boiling.play("boiling")
	
	if bypass_splash:
		splash_timer.wait_time = 0.01
	
	splash_timer.start()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action"):
		_end_splash()


func _end_splash() -> void:
	splash_ended.emit()
	queue_free()

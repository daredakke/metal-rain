class_name PointDefence
extends Node2D


signal gun_fired(shake_strength: float, shake_speed: float)
signal ammo_changed(value: int)

const SHAKE_STRENGTH: float = 4.0
const SHAKE_SPEED: float = 30.0
const PLAYER_BULLET: PackedScene = preload("res://scenes/player_bullet.tscn")

var ammo_left: int = 5:
	set(value):
		ammo_left = clampi(value, 0, 39)
		
		ammo_changed.emit(ammo_left)

var _shots_fired: int = 0:
	set(value):
		_shots_fired = clampi(value, 0, 39)
		
		ammo_changed.emit(ammo_left - _shots_fired)

@onready var gun_1: Gun = %Gun1
@onready var gun_2: Gun = %Gun2
@onready var guns: Array[Gun] = [gun_1, gun_2]
@onready var reload_timer: Timer = %ReloadTimer


func _process(_delta: float) -> void:
	if _shots_fired >= ammo_left:
		return
	
	if Input.is_action_just_pressed("action") and reload_timer.is_stopped():
		var gun_to_fire_index: int = _shots_fired % 2
		guns[gun_to_fire_index].fire_bullet(PLAYER_BULLET)
		_shots_fired += 1
		
		reload_timer.start()
		gun_fired.emit(SHAKE_STRENGTH, SHAKE_SPEED)


func reset() -> void:
	_shots_fired = 0
	
	for node in get_children():
		if node is PlayerBullet:
			remove_child(node)
			node.queue_free()
	
	reload_timer.start()


func _on_reload_timer_timeout() -> void:
	if _shots_fired >= ammo_left:
		return
	
	var ready_to_fire: int = 0
	
	for gun in guns:
		if gun.ready_indicator.visible:
			ready_to_fire += 1
	
	if ready_to_fire == 0:
		var gun_index: int = _shots_fired % 2
		guns[gun_index].ready_indicator.visible = true

class_name PointDefence
extends Node2D


signal gun_fired(shake_strength: float, shake_speed: float)
signal ammo_changed(value: int)

const STARTING_AMMO: int = 7
const SHAKE_STRENGTH: float = 4.0
const SHAKE_SPEED: float = 30.0
const PLAYER_BULLET: PackedScene = preload("res://scenes/player_bullet.tscn")

var ammo_left: int:
	set(value):
		ammo_left = clampi(value, 0, 39)

var _shots_fired: int:
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
		var gun_to_fire_index: int
		
		if guns[0].is_active and guns[1].is_active:
			gun_to_fire_index = _shots_fired % 2
		
		if not guns[0].is_active:
			gun_to_fire_index = 1
		
		if not guns[1].is_active:
			gun_to_fire_index = 0
			
		if not guns[gun_to_fire_index].fire_bullet(PLAYER_BULLET):
			return
		
		_shots_fired += 1
		
		reload_timer.start()
		gun_fired.emit(SHAKE_STRENGTH, SHAKE_SPEED)


func restock_ammo(ammo_restock = 0) -> void:
	ammo_left = (ammo_left - _shots_fired) + ammo_restock
	_shots_fired = 0
	
	reload_timer.start()


func reset() -> void:
	ammo_left = STARTING_AMMO
	_shots_fired = 0
	
	for node in get_children():
		if node is PlayerBullet:
			remove_child(node)
			node.queue_free()
	
	for gun in guns:
		gun.restore()
	
	reload_timer.start()


func _on_reload_timer_timeout() -> void:
	if _shots_fired >= ammo_left:
		return
	
	if not guns[0].is_active:
		guns[1].ready_indicator.show()
		return
	
	if not guns[1].is_active:
		guns[0].ready_indicator.show()
		return
	
	for gun in guns:
		if gun.ready_indicator.visible:
			return
	
	var gun_index: int = _shots_fired % 2
	guns[gun_index].ready_indicator.show()

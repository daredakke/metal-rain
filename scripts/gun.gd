class_name Gun
extends Area2D


signal gun_damaged
signal gun_destroyed

const MAX_HP: int = 8
const MIN_FIRE_RANGE: int = 32

var is_active: bool = true

var _hp: int = MAX_HP:
	set(value):
		_hp = clampi(value, 0, MAX_HP)
		
		if _hp == 1:
			modulate = Color.from_hsv(1.0, 0.6, 1.0, 1.0)
		
		if _hp == 0:
			is_active = false
			
			collision.set_deferred("disabled", true)
			hide()
			gun_destroyed.emit()

@onready var body: Sprite2D = $Body
@onready var barrel: Sprite2D = $Barrel
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var ready_indicator: Sprite2D = $ReadyIndicator


func _process(_delta: float) -> void:
	if not is_active:
		return
	
	barrel.look_at(get_global_mouse_position())
	barrel.rotation = deg_to_rad(clampf(barrel.rotation_degrees, -160, -20))


func fire_bullet(bullet_scene: PackedScene) -> bool:
	if body.global_position.distance_to(get_global_mouse_position()) < MIN_FIRE_RANGE:
		return false
	
	var bullet := bullet_scene.instantiate() as PlayerBullet
	bullet.global_position = barrel.global_position
	bullet.direction = Vector2.RIGHT.rotated(barrel.rotation).normalized()
	bullet.distance_to_travel = global_position.distance_to(get_global_mouse_position())
	
	add_sibling(bullet)
	ready_indicator.hide()
	
	return true


func restore() -> void:
	is_active = true
	collision.disabled = false
	_hp = MAX_HP
	
	ready_indicator.hide()
	modulate = Color.from_hsv(1.0, 0.0, 1.0, 1.0)
	show()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosion") and not area.is_player_explosion:
		_hp -= 1
		
		gun_damaged.emit()

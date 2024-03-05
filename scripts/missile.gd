class_name Missile
extends Area2D


signal missile_destroyed
signal child_destroyed

const EXPLOSION_SCENE: PackedScene = preload("res://scenes/explosion.tscn")
const MISSILE_SCENE: PackedScene = preload("res://scenes/missile.tscn")
const MISSILE_TRAIL_SCENE: PackedScene = preload("res://scenes/missile_trail.tscn")

var speed: float = 13.0
var direction: Vector2
var is_mirv: bool = false
var mirv_split_y: int = randi_range(16, 32)
var mirv_salvo: int = randi_range(2, 4)

var _is_active: bool = true
var _explosion_scale := Vector2(0.2, 0.2)
var _children_destroyed: int = 0

@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	rotation = direction.angle()


func _process(delta) -> void:
	if not _is_active:
		return
	
	position += direction * speed * delta
	
	if is_mirv and global_position.y > mirv_split_y:
		_split()


func destroy() -> void:
	missile_destroyed.emit()
	child_destroyed.emit()

	queue_free()


func explode() -> void:
	var explosion := EXPLOSION_SCENE.instantiate() as Explosion
	explosion.global_position = global_position
	explosion.scale = _explosion_scale
	
	add_sibling(explosion)
	destroy()


func _split() -> void:
	_is_active = false
	collision.disabled = true
	
	hide()
	
	for i in mirv_salvo:
		var missile := MISSILE_SCENE.instantiate() as Missile
		missile.global_position = global_position
		missile.direction = direction.rotated(deg_to_rad((i * 10) - mirv_salvo * 0.5))
		
		add_sibling(missile)
		
		var missile_trail := MISSILE_TRAIL_SCENE.instantiate() as MissileTrail
		missile_trail.node_to_follow = missile
		missile_trail.set_anchor(global_position)
		missile_trail.hide()
		missile.missile_destroyed.connect(missile_trail.destroy)
		missile.child_destroyed.connect(_child_missile_destroyed)
		
		add_sibling(missile_trail)


func _child_missile_destroyed() -> void:
	_children_destroyed += 1
	
	if _children_destroyed >= mirv_salvo:
		destroy()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		return
	
	if area.is_in_group("explosion"):
		if area.is_player_explosion:
			Global.missiles_shot_down += 1
			destroy()
	else:
		call_deferred("explode")

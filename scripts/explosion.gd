class_name Explosion
extends Area2D


var is_player_explosion: bool = false

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var damage_duration: Timer = $DamageDuration
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("fade_out")


func _on_damage_duration_timeout() -> void:
	collision_shape_2d.queue_free()


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()

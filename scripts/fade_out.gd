class_name FadeOut
extends Control


signal fade_out_complete

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	hide()


func start() -> void:
	show()
	animation_player.play("fade_out")


func _on_animation_finished(_anim_name: StringName) -> void:
	hide()
	fade_out_complete.emit()

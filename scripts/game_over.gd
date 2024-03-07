class_name GameOver
extends Control


@onready var close_button: Button = %CloseButton
@onready var missiles_destroyed_value: Label = %MissilesDestroyedValue
@onready var days_lasted_value: Label = %DaysLastedValue


func _ready() -> void:
	hide()


func _on_close_button_pressed() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		missiles_destroyed_value.text = str(Global.missiles_shot_down)
		days_lasted_value.text = str(Global.level)

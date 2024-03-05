class_name Hud
extends Control


const MAX_INDICATORS: int = 39
const SHOT_INDICATOR_SCENE: PackedScene = preload("res://scenes/shot_indicator.tscn")

@onready var ammo_left: HBoxContainer = %AmmoLeft


func _ready() -> void:
	# Create enough shot indicators to fill the screen width
	for i in MAX_INDICATORS:
		var shot_indicator := SHOT_INDICATOR_SCENE.instantiate() as TextureRect
		shot_indicator.visible = false
		ammo_left.add_child(shot_indicator)


func display_shot_indicators(count: int) -> void:
	for indicator in ammo_left.get_children():
		indicator.visible = false
	
	for i in count:
		ammo_left.get_child(i).visible = true



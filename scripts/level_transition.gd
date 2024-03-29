class_name LevelTransition
extends Control


signal initial_transition_finished
signal level_transitioned

var messages: Array[String] = [
	"THEY WON'T STOP",
	"THE END IS NIGH",
	"HELP ISN'T COMING",
	"YOU CAN'T SAVE THEM",
	"NO FUTURE FOR YOU",
	"A FUTILE EFFORT",
	"TIME TO GIVE UP",
	"THERE IS NO POINT",
	"ONLY DESPAIR WILL REMAIN",
	"WHAT CAN YOU DO?",
	"ABANDON HOPE",
	"WHY DO YOU PERSIST?",
	"A HOPELESS PLIGHT",
	"ALL FOR NOTHING",
	"ONLY A MATTER OF TIME",
	"LIFELESS BARREN EARTH",
	"DEAD BLACK ASTEROID",
	"THIS WORLD IS A TOMB",
	"ALL WILL PERISH",
	"SAY YOUR PRAYERS",
	"THIS PLACE IS YOUR GRAVE",
	"A LONG SILENCE WILL FOLLOW",
	"THERE ARE NO WINNERS",
	"NO ESCAPE FROM FATE",
	"ALL IS OVER",
	"THE NEXT GREAT FLOOD COMES",
	"THE SKY IS FALLING",
	"CLEANSE THE EARTH",
	"DUST AND ECHOES",
	"YOUR GRAVE BECKONS",
	"WHERE IS YOUR GOD?",
	"HELL ON EARTH",
	"UNTIL ALL ARE DEAD",
	"CUT DOWN BY THE REAPER",
	"THERE IS NOTHING YOU CAN DO",
	"YOU WON'T LAST FOREVER",
	"HEED THE REAPER'S CALL",
	"FACE THE TRUTH",
	"YOU CAN'T CHANGE THE OUTCOME",
	"YOU KNOW HOW THIS ENDS",
	"THE FIRES CONSUME ALL",
	"FUNERAL FOR THE DAMNED",
	"A NEW CIRCLE OF HELL",
	"NOT WORTH THE EFFORT",
]

var _message_index: int = 0:
	set(value):
		_message_index = value
		
		if _message_index >= messages.size():
			_message_index = 0
var _split_message: PackedStringArray
var _word_index: int = 0
var _intro_transition: bool = false

@onready var transition_panel: Panel = %TransitionPanel
@onready var message_label: Label = %MessageLabel
@onready var level_v_box: VBoxContainer = %LevelVBox
@onready var level_label: Label = %LevelLabel
@onready var fade_out: AnimationPlayer = %FadeOut
@onready var word_duration: Timer = %WordDuration


func _ready() -> void:
	hide()


func shuffle_messages() -> void:
	messages.shuffle()


func start(current_level: int) -> void:
	# Ensure level transition is fully opaque
	modulate = Color.from_hsv(1.0, 0.0, 1.0, 1.0)
	_intro_transition = true if current_level == 1 else false
	
	show()
	
	level_label.text = str(current_level)
	_split_message = messages[_message_index].split(" ")
	message_label.text = _split_message[_word_index]
	_word_index += 1
	_message_index += 1
	
	transition_panel.show()
	message_label.show()
	level_v_box.hide()
	word_duration.start()
	Global.transition_message_shown.emit()


func _show_level_message() -> void:
	transition_panel.hide()
	message_label.hide()
	level_v_box.show()
	
	fade_out.play("fade_out")
	Global.transition_level_shown.emit()


func _on_word_duration_timeout() -> void:
	if _word_index >= _split_message.size():
		_word_index = 0
		word_duration.stop()
		_show_level_message()
		return
	
	message_label.text = _split_message[_word_index]
	_word_index += 1
	Global.transition_message_shown.emit()


func _on_fade_out_animation_finished(_anim_name: StringName) -> void:
	fade_out.stop()
	hide()
	
	if _intro_transition:
		initial_transition_finished.emit()
	else:
		level_transitioned.emit()

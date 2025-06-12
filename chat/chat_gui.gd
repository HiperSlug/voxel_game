extends Control
class_name ChatGUI

@export var chat_input: LineEdit
@export var chat_container: VBoxContainer
@export var cmd_parser: CMDParser

@export var chat_message_scene: PackedScene

signal start_chatting()
signal done_chatting()

var chatting: bool = false
var can_submit: bool = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("chat"):
		can_submit = true
		if not chatting:
			enter_chat()
	
	elif event.is_action_pressed("cmd") and not chatting:
		enter_chat()
		chat_input.text = "/"
	
	if not chat_input.has_focus():
		return
	
	elif event.is_action_pressed("past_chat"):
		
		if -1 * (chat_message_index - 1) > past_chat_messages.size():
			return
			
		chat_message_index -= 1
		chat_input.text = past_chat_messages[chat_message_index]

	elif event.is_action_pressed("recent_chat"):
		chat_message_index += 1
		
		if chat_message_index >= 0:
			chat_message_index = 0
			chat_input.text = ""
			return
		
		chat_input.text = past_chat_messages[chat_message_index]


var past_chat_messages: Array[String] = []
var chat_message_index: int = 0

func _on_chat_input_text_submitted(message: String) -> void:
	if not can_submit:
		return
	
	if message == "":
		exit_chat()
		return
	
	past_chat_messages.append(message)
	
	if message.begins_with("/"):
		cmd_parser.parse_cmd(message)
		exit_chat()
		return
	
	push_message(message)
	
	exit_chat()

func exit_chat() -> void:
	chatting = false
	chat_input.text = ""
	chat_input.release_focus()
	done_chatting.emit()
	chat_message_index = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func enter_chat() -> void:
	can_submit = false
	chatting = true
	chat_input.text = ""
	chat_input.grab_focus()
	start_chatting.emit()
	chat_message_index = 0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func push_message(message: String) -> void:
	var label: Label = chat_message_scene.instantiate()
	label.text = message
	chat_container.add_child(label)


func system_message(message: String) -> void:
	var wrapped_message: String = "sys: {0}".format([message])
	push_message(wrapped_message)

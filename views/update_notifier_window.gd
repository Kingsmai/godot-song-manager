extends Window
class_name UpdateNotifierWindow

signal confirmed

@onready var dialog_text_label: Label = %DialogTextLabel
@onready var confirm_button: Button = %ConfirmButton

var dialog_text:
	set(value):
		dialog_text = value

func _ready() -> void:
	dialog_text_label.text = dialog_text
	confirm_button.pressed.connect(func (): confirmed.emit())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		self.hide()

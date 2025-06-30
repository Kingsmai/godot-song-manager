@tool
extends PanelContainer

"""
## NOTE:
1.this three setting must be true if you want a transparent background!
	ProjectSettings.set("display/window/size/borderless", true)
	ProjectSettings.set("display/window/size/transparent", true)
	ProjectSettings.set("rendering/viewport/transparent_background", true)

2.top level of container grow direction needs to be Right and Bottom
"""

@export var window_min_size := Vector2i(800, 600):
	set(value):
		window_min_size = value
		if is_node_ready():
			window_resize_component.min_size = window_min_size
@export var program_title: String:
	set(value):
		program_title = value
		%ProgramTitleLabel.text = value

@onready var program_title_label: Label = %ProgramTitleLabel

@onready var exit_button: Button = %ExitButton
@onready var maximize_button: Button = %MaximizeButton
@onready var restore_button: Button = %RestoreButton
@onready var minimize_button: Button = %MinimizeButton

@onready var window_state_component = %WindowStateComponent
@onready var window_drag_component = %WindowDragComponent
@onready var window_resize_component = %WindowResizeComponent

func _ready():
	window_min_size = window_min_size
	minimize_button.pressed.connect(window_state_component.set_minimized)
	maximize_button.pressed.connect(_on_maximize_button_pressed)
	restore_button.pressed.connect(_on_restore_button_pressed)
	exit_button.pressed.connect(window_state_component.quit)
	
	window_drag_component.drag_started.connect(func(): window_resize_component.activate = false)
	window_drag_component.drag_stoped.connect(func(): window_resize_component.activate = true)
	
	program_title_label.text = LocalizationManager.tr("PROGRAM_TITLE")

# func _process(delta):
# 	var is_resize = window_resize_component.is_waiting_resize() or window_resize_component.is_resizing()
# 	minimize_button.disabled = is_resize
# 	maximize_button.disabled = is_resize
# 	exit_button.disabled = is_resize

func _on_maximize_button_pressed():
	restore_button.show()
	maximize_button.hide()
	window_state_component.toggle_maximized()

func _on_restore_button_pressed():
	restore_button.hide()
	maximize_button.show()
	window_state_component.set_windowed()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if window_resize_component.is_waiting_resize():
				window_resize_component.start_resize()
				get_viewport().set_input_as_handled()
		elif not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			if window_resize_component.is_resizing():
				window_resize_component.stop_resize()
				get_viewport().set_input_as_handled()
				
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if window_resize_component.is_resizing():
				get_viewport().set_input_as_handled()
			
func _notification(what):
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		pass
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		if window_resize_component.is_resizing():
			window_resize_component.stop_resize()
		if window_drag_component.is_dragging():
			window_drag_component.stop_drag()
	elif what == NOTIFICATION_TRANSLATION_CHANGED:
		if program_title_label:
			program_title_label.text = LocalizationManager.tr("PROGRAM_TITLE")
			
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				pass
			elif window_drag_component.is_dragging():
				window_drag_component.stop_drag()
		
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if window_state_component.is_maxsimized():
				# 全屏状态下拖拽会缩小窗口
				window_state_component.set_windowed()
				var win_size = DisplayServer.window_get_size() * 0.5
				DisplayServer.window_set_position(DisplayServer.mouse_get_position() - Vector2i(win_size.x, 20))
			if not window_drag_component.is_dragging():
				window_drag_component.start_drag()

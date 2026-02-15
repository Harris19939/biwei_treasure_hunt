# 虚拟摇杆控制器
# 用于移动端触摸控制

class_name TouchJoystick
extends Control

## 摇杆底座半径
@export var base_radius: float = 60.0
## 摇杆杆半径
@export var stick_radius: float = 30.0
## 最大拖拽距离
@export var max_drag_distance: float = 50.0
## 触摸ID
var touch_index: int = -1
## 摇杆中心位置
var center_position: Vector2 = Vector2.ZERO
## 当前摇杆位置
var current_stick_position: Vector2 = Vector2.ZERO
## 输出方向向量 (-1 到 1)
var output_vector: Vector2 = Vector2.ZERO
## 是否正在使用
var is_active: bool = false
## 摇杆是否可见
var is_visible: bool = true

@onready var base_color := Color(1, 1, 1, 0.3)
@onready var stick_color := Color(1, 1, 1, 0.6)

func _ready():
	# 设置控件大小
	custom_minimum_size = Vector2(base_radius * 2, base_radius * 2)
	# 初始位置在左下角
	position = Vector2(20, -base_radius * 2 - 20)

func _draw():
	if not is_visible:
		return
	# 绘制底座
	draw_circle(center_position, base_radius, base_color)
	# 绘制边框
	draw_arc(center_position, base_radius, 0, TAU, 32, Color(1, 1, 1, 0.5), 2.0)
	# 绘制摇杆
	draw_circle(current_stick_position, stick_radius, stick_color)

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# 首次触摸
			if touch_index == -1:
				touch_index = event.index
				center_position = event.position
				current_stick_position = event.position
				is_active = true
				queue_redraw()
		else:
			# 触摸结束
			if event.index == touch_index:
				_reset_joystick()
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			_update_stick_position(event.position)

func _update_stick_position(screen_pos: Vector2):
	var direction = screen_pos - center_position
	var distance = direction.length()
	
	if distance > max_drag_distance:
		direction = direction.normalized() * max_drag_distance
	
	current_stick_position = center_position + direction
	output_vector = direction / max_drag_distance
	
	# 限制在 -1 到 1 之间
	output_vector = output_vector.clamp(Vector2(-1, -1), Vector2(1, 1))
	
	queue_redraw()

func _reset_joystick():
	touch_index = -1
	current_stick_position = center_position
	output_vector = Vector2.ZERO
	is_active = false
	queue_redraw()

func get_input_vector() -> Vector2:
	return output_vector

func show_joystick():
	is_visible = true
	visible = true
	queue_redraw()

func hide_joystick():
	is_visible = false
	visible = false
	queue_redraw()

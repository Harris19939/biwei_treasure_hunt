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
## 摇杆中心位置 (屏幕坐标)
var center_position: Vector2 = Vector2.ZERO
## 当前摇杆位置 (相对于本控件)
var local_stick_position: Vector2 = Vector2.ZERO
## 输出方向向量 (-1 到 1)
var output_vector: Vector2 = Vector2.ZERO
## 是否正在使用
var is_active: bool = false
## 摇杆是否可见
var is_visible: bool = true
## 是否已初始化
var initialized: bool = false

@onready var base_color := Color(1, 1, 1, 0.3)
@onready var stick_color := Color(1, 1, 1, 0.6)

func _ready():
	# 设置控件大小为全屏，用于接收触摸事件
	custom_minimum_size = Vector2(300, 300)
	# 锚点设为左下
	anchors_preset = Control.PRESET_BOTTOM_LEFT
	# 从左边距开始
	offset_left = 10
	offset_top = -300
	offset_bottom = 0
	offset_right = 310

func _process(_delta):
	# 在第一次运行时设置中心位置
	if not initialized:
		initialized = true
		var screen_size = get_viewport().get_visible_rect().size
		# 中心在左下角
		center_position = Vector2(base_radius + 20, screen_size.y - base_radius - 20)
		local_stick_position = center_position
		queue_redraw()

func _draw():
	if not is_visible:
		return
	# 获取屏幕尺寸计算实际位置
	var screen_size = get_viewport().get_visible_rect().size
	var base_center = Vector2(base_radius + 20, screen_size.y - base_radius - 20)
	
	# 绘制底座
	draw_circle(base_center, base_radius, base_color)
	# 绘制边框
	draw_arc(base_center, base_radius, 0, TAU, 32, Color(1, 1, 1, 0.5), 2.0)
	# 绘制摇杆
	draw_circle(local_stick_position, stick_radius, stick_color)

func _gui_input(event):
	# 获取屏幕尺寸
	var screen_size = get_viewport().get_visible_rect().size
	
	if event is InputEventScreenTouch:
		if event.pressed:
			# 检查是否触摸在摇杆区域 (左侧区域)
			if event.position.x < 250 and event.position.y > screen_size.y - 250:
				# 首次触摸
				if touch_index == -1:
					touch_index = event.index
					center_position = event.position
					local_stick_position = event.position
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
	var screen_size = get_viewport().get_visible_rect().size
	var base_center = Vector2(base_radius + 20, screen_size.y - base_radius - 20)
	
	var direction = screen_pos - base_center
	var distance = direction.length()
	
	if distance > max_drag_distance:
		direction = direction.normalized() * max_drag_distance
	
	local_stick_position = base_center + direction
	output_vector = direction / max_drag_distance
	
	# 限制在 -1 到 1 之间
	output_vector = output_vector.clamp(Vector2(-1, -1), Vector2(1, 1))
	
	queue_redraw()

func _reset_joystick():
	touch_index = -1
	var screen_size = get_viewport().get_visible_rect().size
	local_stick_position = Vector2(base_radius + 20, screen_size.y - base_radius - 20)
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

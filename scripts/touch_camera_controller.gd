# 触摸视角控制器
# 用于移动端视角控制

class_name TouchCameraController
extends Control

## 灵敏度
@export var sensitivity: float = 0.005
## 旋转X轴限制
var rotation_x_limit: float = PI / 2

## 当前触摸ID
var touch_index: int = -1
## 上次触摸位置
var last_touch_position: Vector2 = Vector2.ZERO

## 相机旋转回调 [horizontal, vertical]
signal camera_rotated(horizontal: float, vertical: float)

## 是否正在使用
var is_active: bool = false

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# 右侧区域用于视角控制
			var screen_size = get_viewport().get_visible_rect().size
			var right_half = Rect2(screen_size.x / 2, 0, screen_size.x / 2, screen_size.y)
			
			if right_half.has_point(event.position) and touch_index == -1:
				touch_index = event.index
				last_touch_position = event.position
				is_active = true
		else:
			if event.index == touch_index:
				touch_index = -1
				is_active = false
	elif event is InputEventScreenDrag:
		if event.index == touch_index:
			var delta = event.position - last_touch_position
			last_touch_position = event.position
			
			# 发出旋转信号
			camera_rotated.emit(-delta.x * sensitivity, -delta.y * sensitivity)

func is_touch_active() -> bool:
	return is_active

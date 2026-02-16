# 触摸动作按钮
# 用于跳跃、交互等动作

class_name TouchActionButtons
extends Control

## 按钮配置
@export var button_size: Vector2 = Vector2(80, 80)
## 按钮间距
@export var button_spacing: float = 20.0

## 跳跃按钮是否按下
var jump_pressed: bool = false
## 交互按钮是否按下
var interact_pressed: bool = false

var jump_button_pos: Vector2
var interact_button_pos: Vector2

# 按钮区域
var jump_area: Rect2
var interact_area: Rect2

# 按钮状态
var jump_touch_index: int = -1
var interact_touch_index: int = -1

# 颜色
var base_color := Color(1, 1, 1, 0.3)
var pressed_color := Color(0.3, 0.8, 0.3, 0.6)
var interact_color := Color(0.8, 0.6, 0.3, 0.6)
var border_color := Color(1, 1, 1, 0.5)

# 是否已初始化
var initialized: bool = false

func _ready():
	# 设置控件大小为全屏，用于接收触摸事件
	custom_minimum_size = Vector2(400, 400)
	# 锚点设为右下
	anchors_preset = Control.PRESET_BOTTOM_RIGHT
	# 偏移设置
	offset_left = -400
	offset_top = -400
	offset_right = 0
	offset_bottom = 0

func _process(_delta):
	# 计算按钮区域 (相对于右下角)
	var screen_size = get_viewport().get_visible_rect().size
	var right = screen_size.x - 20
	var bottom = screen_size.y - 20
	
	# 跳跃按钮在右下角左侧
	jump_area = Rect2(
		right - button_size.x * 2 - button_spacing - 100,
		bottom - button_size.y,
		button_size.x,
		button_size.y
	)
	
	# 交互按钮在跳跃按钮上方
	interact_area = Rect2(
		right - button_size.x * 2 - button_spacing - 100,
		bottom - button_size.y * 2 - button_spacing,
		button_size.x,
		button_size.y
	)
	
	queue_redraw()

func _draw():
	# 绘制跳跃按钮
	var jump_color = pressed_color if jump_pressed else base_color
	draw_rect(jump_area, jump_color)
	draw_rect(jump_area, border_color, false, 2.0)
	draw_string(ThemeDB.fallback_font, jump_area.get_center() + Vector2(-15, 5), "跳跃", HORIZONTAL_ALIGNMENT_CENTER, -1, 24)
	
	# 绘制交互按钮
	var interact_color_final = pressed_color if interact_pressed else interact_color
	draw_rect(interact_area, interact_color_final)
	draw_rect(interact_area, border_color, false, 2.0)
	draw_string(ThemeDB.fallback_font, interact_area.get_center() + Vector2(-15, 5), "交互", HORIZONTAL_ALIGNMENT_CENTER, -1, 24)

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			var touch_pos = event.position
			
			# 检查跳跃按钮 (右侧区域)
			if touch_pos.x > get_viewport().get_visible_rect().size.x - 300:
				if jump_area.has_point(touch_pos) and jump_touch_index == -1:
					jump_touch_index = event.index
					jump_pressed = true
					queue_redraw()
				elif interact_area.has_point(touch_pos) and interact_touch_index == -1:
					interact_touch_index = event.index
					interact_pressed = true
					queue_redraw()
		else:
			# 触摸结束
			if event.index == jump_touch_index:
				jump_touch_index = -1
				jump_pressed = false
				queue_redraw()
			elif event.index == interact_touch_index:
				interact_touch_index = -1
				interact_pressed = false
				queue_redraw()

func is_jump_pressed() -> bool:
	return jump_pressed

func is_interact_pressed() -> bool:
	return interact_pressed

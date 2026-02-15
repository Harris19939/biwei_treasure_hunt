# 触摸控制系统
# 管理所有移动端触摸控制

class_name TouchControlsManager
extends CanvasLayer

## 虚拟摇杆
@onready var joystick: TouchJoystick = $Joystick
## 动作按钮
@onready var action_buttons: TouchActionButtons = $ActionButtons
## 视角控制器
@onready var camera_controller: TouchCameraController = $CameraController

## 回调节点 (玩家控制器)
var player_controller: Node3D = null

func _ready():
	# 默认隐藏，只有在移动端才显示
	if not DisplayServer.is_touchscreen_available():
		hide_all()
	else:
		show_all()

func _process(_delta):
	# 更新回调
	if player_controller and player_controller.has_method("set_touch_input"):
		# 发送摇杆输入
		player_controller.set_touch_input("move", joystick.get_input_vector())
		
		# 发送按钮状态
		player_controller.set_touch_input("jump", action_buttons.is_jump_pressed())
		player_controller.set_touch_input("interact", action_buttons.is_interact_pressed())

func _on_camera_rotated(horizontal: float, vertical: float):
	if player_controller and player_controller.has_method("handle_touch_camera"):
		player_controller.handle_touch_camera(horizontal, vertical)

func connect_player(controller: Node3D):
	player_controller = controller
	# 连接视角旋转信号
	camera_controller.camera_rotated.connect(_on_camera_rotated)

func show_all():
	joystick.visible = true
	action_buttons.visible = true
	camera_controller.visible = true

func hide_all():
	joystick.visible = false
	action_buttons.visible = false
	camera_controller.visible = false

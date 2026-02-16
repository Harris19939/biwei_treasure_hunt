# 2D玩家控制器
# 极简2D风格 - 圆形玩家 + 方向线

extends CharacterBody2D

## 移动参数
@export var move_speed: float = 200.0
@export var acceleration: float = 1000.0
@export var friction: float = 800.0

## 触摸输入向量
var touch_input: Vector2 = Vector2.ZERO

## 节点引用
@onready var visuals: Node2D = $Visuals
@onready var direction_line: Line2D = $Visuals/DirectionLine
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = 16.0
	collision_shape.shape = shape
	
	direction_line.default_color = Color(1, 1, 1, 0.8)
	direction_line.width = 2.0
	direction_line.points = [Vector2.ZERO, Vector2(0, -30)]
	direction_line.visible = true

func _physics_process(delta: float):
	var input_direction = _get_input_direction()
	
	if touch_input.length() > 0.1:
		input_direction = touch_input.normalized()
	
	if input_direction.length() > 0:
		velocity = velocity.move_toward(input_direction * move_speed, acceleration * delta)
		visuals.rotation = input_direction.angle() + PI/2
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if velocity.length() < 5.0:
			velocity = Vector2.ZERO
	
	move_and_slide()
	_update_direction_line()

func _get_input_direction() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		direction.y -= 1
	if Input.is_action_pressed("move_back"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	return direction.normalized()

func _update_direction_line():
	if velocity.length() > 10:
		var angle = velocity.angle() + PI/2
		direction_line.rotation = angle - visuals.rotation

func set_touch_input(input: Vector2):
	touch_input = input

func get_position_2d() -> Vector2:
	return global_position

# 玩家控制器
# 处理移动、视角、交互、背包同步

class_name PlayerController
extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@onready var camera: Camera3D = $Camera3D
@onready var interaction_ray: RayCast3D = $InteractionRay

var player_id: int
var inventory: Inventory = Inventory.new()
var health: int = 100
var is_local_player: bool = false

# 触摸输入状态
var touch_move_input: Vector2 = Vector2.ZERO
var touch_jump_pressed: bool = false
var touch_interact_pressed: bool = false
var touch_jump_was_pressed: bool = false
var touch_interact_was_pressed: bool = false
# 是否使用触摸模式
var use_touch_controls: bool = false

func _ready():
	if is_local_player:
		camera.current = true
		# 检测是否为触屏设备
		use_touch_controls = DisplayServer.is_touchscreen_available()
		if use_touch_controls:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameManager.register_player(player_id, self)

func _physics_process(delta):
	if not is_local_player:
		return
	_handle_movement(delta)
	_handle_interaction()
	_move_and_sync()

func _handle_movement(delta):
	# 获取键盘输入
	var keyboard_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# 合并触摸和键盘输入
	var input_dir = keyboard_input_dir
	if use_touch_controls and touch_move_input != Vector2.ZERO:
		input_dir = touch_move_input
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 地面移动
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# 重力
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 跳跃 (键盘或触摸)
	var jump_pressed = Input.is_action_just_pressed("jump") or (touch_jump_pressed and not touch_jump_was_pressed)
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity
	
	# 更新触摸状态
	touch_jump_was_pressed = touch_jump_pressed
	touch_interact_was_pressed = touch_interact_pressed

func _move_and_sync():
	move_and_slide()
	# 同步位置到网络
	if multiplayer.has_multiplayer_peer():
		sync_position.rpc(global_position, rotation)

func _handle_interaction():
	# 键盘或触摸交互
	var interact_pressed = Input.is_action_just_pressed("interact") or (touch_interact_pressed and not touch_interact_was_pressed)
	if interact_pressed:
		if interaction_ray.is_colliding():
			var target = interaction_ray.get_collider()
			if target.has_method("interact"):
				target.interact(self)

func _input(event):
	if not is_local_player:
		return
	
	# 触摸模式不处理鼠标视角
	if not use_touch_controls:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(-event.relative.y * mouse_sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

# 设置触摸输入 (从 TouchControlsManager 调用)
func set_touch_input(action: String, value):
	match action:
		"move":
			touch_move_input = value
		"jump":
			touch_jump_pressed = value
		"interact":
			touch_interact_pressed = value

# 处理触摸视角旋转
func handle_touch_camera(horizontal: float, vertical: float):
	rotate_y(horizontal)
	camera.rotate_x(vertical)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

@rpc("unreliable")
func sync_position(pos: Vector3, rot: Vector3):
	if not is_local_player:
		global_position = pos
		rotation = rot

@rpc("any_peer", "call_local")
func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	print("[Player] 玩家死亡:", player_id)
	GameManager.player_died.emit(player_id)
	# 掉落所有物品
	drop_all_items()

func drop_all_items():
	for i in range(inventory.slots.size() - 1, -1, -1):
		var item = inventory.remove_item(i)
		if item:
			spawn_dropped_item(item)

func spawn_dropped_item(item: ItemData):
	# TODO: 在场景中生成掉落物品
	print("[Player] 掉落物品:", item.name)

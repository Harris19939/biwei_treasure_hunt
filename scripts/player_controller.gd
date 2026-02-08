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

func _ready():
	if is_local_player:
		camera.current = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		GameManager.register_player(player_id, self)

func _physics_process(delta):
	if not is_local_player:
		return
	_handle_movement(delta)
	_handle_interaction()
	_move_and_sync()

func _handle_movement(delta):
	# 获取输入
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
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
	
	# 跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _move_and_sync():
	move_and_slide()
	# 同步位置到网络
	if multiplayer.has_multiplayer_peer():
		sync_position.rpc(global_position, rotation)

func _handle_interaction():
	if Input.is_action_just_pressed("interact"):
		if interaction_ray.is_colliding():
			var target = interaction_ray.get_collider()
			if target.has_method("interact"):
				target.interact(self)

func _input(event):
	if not is_local_player:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
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

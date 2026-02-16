# 游戏世界脚本
# 管理游戏场景、玩家生成、物品刷新

extends Node3D

@onready var players_node: Node3D = $Players
@onready var items_node: Node3D = $Items
@onready var spawn_points: Node3D = $SpawnPoints

var timer_label: Label

var player_scene = preload("res://scenes/player.tscn")

func _ready():
	print("[GameWorld] 游戏世界加载开始")
	
	# 安全获取节点
	timer_label = $UI/HUD/TimerLabel if has_node("UI/HUD/TimerLabel") else null
	
	# 连接信号 (带错误处理)
	if GameManager.has_signal("game_timer_updated"):
		GameManager.game_timer_updated.connect(_on_timer_updated)
	
	# 单机版：直接开始游戏
	GameManager.start_game()
	
	# 生成本地玩家
	spawn_local_player()
	
	# 单机版：生成一些测试物品
	spawn_test_items()
	
	print("[GameWorld] 游戏世界加载完成")

func _on_timer_updated(time_left: float):
	if timer_label:
		var minutes = int(time_left) / 60
		var seconds = int(time_left) % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func spawn_local_player():
	if not player_scene:
		print("[GameWorld] 错误: 无法加载玩家场景")
		return
	
	var player = player_scene.instantiate()
	player.player_id = NetworkManager.get_player_id()
	player.is_local_player = true
	
	# 选择出生点
	var spawn_index = players_node.get_child_count()
	var spawn_point = spawn_points.get_child(spawn_index % spawn_points.get_child_count())
	player.global_position = spawn_point.global_position
	
	players_node.add_child(player)
	print("[GameWorld] 本地玩家生成完成:", player.player_id)
	
	# 连接触摸控制到玩家 (带错误处理)
	if has_node("TouchControls"):
		var touch_controls = get_node("TouchControls")
		if touch_controls and touch_controls.has_method("connect_player"):
			touch_controls.connect_player(player)
			print("[GameWorld] 触摸控制已连接")

func _on_player_connected(id: int):
	print("[GameWorld] 新玩家连接:", id)

func _input(event):
	if event.is_action_pressed("inventory"):
		_toggle_inventory()

func _toggle_inventory():
	print("[GameWorld] 切换背包显示")

# 单机版：生成测试物品
func spawn_test_items():
	print("[GameWorld] 生成测试物品...")
	
	# 在地图上随机生成一些立方体作为可拾取物品
	for i in range(10):
		var item = MeshInstance3D.new()
		item.mesh = BoxMesh.new()
		item.mesh.size = Vector3(0.5, 0.5, 0.5)
		
		# 随机位置
		var x = randf_range(-20, 20)
		var z = randf_range(-20, 20)
		item.position = Vector3(x, 0.5, z)
		
		# 添加碰撞体
		var body = StaticBody3D.new()
		body.collision_layer = 8  # Interactables层
		var collision = CollisionShape3D.new()
		collision.shape = BoxShape3D.new()
		collision.shape.size = Vector3(0.5, 0.5, 0.5)
		body.add_child(collision)
		item.add_child(body)
		
		# 添加交互脚本
		body.set_meta("item_name", "宝箱" + str(i+1))
		body.set_meta("can_pickup", true)
		
		items_node.add_child(item)
	
	print("[GameWorld] 测试物品生成完成")

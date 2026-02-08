# 主菜单脚本
# 处理创建房间、加入房间、退出游戏

extends Control

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var status_label: Label = $StatusLabel

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.player_connected.connect(_on_player_connected)
	
	# 单机版：直接显示单机游戏按钮
	host_button.text = "单机游戏"
	join_button.text = "多人游戏(开发中)"
	join_button.disabled = true

func _on_host_pressed():
	# 单机版：直接进入游戏，无需联网
	status_label.text = "正在启动单机游戏..."
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")

func _on_join_pressed():
	# 多人模式暂未开放
	status_label.text = "多人模式开发中..."

func _on_quit_pressed():
	get_tree().quit()

func _on_connection_failed():
	status_label.text = "连接失败！"

func _on_player_connected(id: int):
	status_label.text = "玩家 " + str(id) + " 已连接"
	if NetworkManager.get_connected_players() >= 1:
		# 至少2人，可以开始游戏
		get_tree().change_scene_to_file("res://scenes/game_world.tscn")

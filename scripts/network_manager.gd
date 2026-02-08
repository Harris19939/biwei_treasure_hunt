# 网络管理器 - 单例
# 负责创建/加入房间、玩家连接管理、RPC封装

extends Node

enum NetworkMode { OFFLINE, HOST, CLIENT }

var mode: NetworkMode = NetworkMode.OFFLINE
var multiplayer: MultiplayerAPI
var peer: ENetMultiplayerPeer

signal player_connected(id: int)
signal player_disconnected(id: int)
signal connection_failed
signal server_disconnected

func _ready():
    print("[NetworkManager] 初始化完成")

# 创建主机
func create_host(port: int = 7777, max_clients: int = 4):
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, max_clients)
    
    if error != OK:
        print("[NetworkManager] 创建主机失败:", error)
        connection_failed.emit()
        return false
    
    multiplayer.multiplayer_peer = peer
    mode = NetworkMode.HOST
    
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    
    print("[NetworkManager] 主机创建成功，端口:", port)
    return true

# 加入主机
func join_host(address: String, port: int = 7777):
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(address, port)
    
    if error != OK:
        print("[NetworkManager] 连接失败:", error)
        connection_failed.emit()
        return false
    
    multiplayer.multiplayer_peer = peer
    mode = NetworkMode.CLIENT
    
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    
    print("[NetworkManager] 正在连接:", address, ":", port)
    return true

# 断开连接
func disconnect_network():
    if peer:
        peer.close()
        peer = null
    mode = NetworkMode.OFFLINE
    print("[NetworkManager] 已断开连接")

func _on_peer_connected(id: int):
    print("[NetworkManager] 玩家连接:", id)
    player_connected.emit(id)

func _on_peer_disconnected(id: int):
    print("[NetworkManager] 玩家断开:", id)
    player_disconnected.emit(id)

func _on_connected_to_server():
    print("[NetworkManager] 已连接到服务器")

func _on_connection_failed():
    print("[NetworkManager] 连接失败")
    mode = NetworkMode.OFFLINE
    connection_failed.emit()

func _on_server_disconnected():
    print("[NetworkManager] 服务器断开")
    mode = NetworkMode.OFFLINE
    server_disconnected.emit()

# 获取当前玩家ID
func get_player_id() -> int:
    return multiplayer.get_unique_id()

# 是否是主机
func is_host() -> bool:
    return mode == NetworkMode.HOST

# 获取连接玩家数量
func get_connected_players() -> int:
    if not peer:
        return 0
    return peer.get_peers().size()

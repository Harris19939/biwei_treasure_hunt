# 必维摸金 - 单机版测试版

**项目**: 260209必维摸金  
**版本**: v0.1.0 单机测试版  
**日期**: 2026-02-08  
**开发者**: 莫邪

---

## 🎮 快速开始

### 1. 下载 Godot 引擎

访问 https://godotengine.org 下载 **Godot 4.x** 版本

### 2. 打开项目

1. 启动 Godot
2. 点击 **"导入"** 按钮
3. 选择项目文件夹：`/项目/260209必维摸金/代码/biwei_treasure_hunt/`
4. 点击 **"导入并编辑"**

### 3. 运行游戏

1. 在Godot编辑器中，点击右上角的 **"运行项目"** 按钮（或按 F5）
2. 看到主菜单后，点击 **"单机游戏"**
3. 进入游戏世界，开始探索！

---

## 🕹️ 操作说明

| 按键 | 功能 |
|------|------|
| W/A/S/D | 移动 |
| 鼠标 | 控制视角 |
| 空格 | 跳跃 |
| E | 交互（拾取物品） |
| I | 打开背包（开发中） |

---

## 🎯 测试内容

- **玩家角色**: 胶囊体模型，可自由移动
- **地图**: 100x100平地方块
- **宝箱**: 10个随机分布的彩色立方体
- **计时器**: 15分钟倒计时

---

## 📝 项目结构

```
biwei_treasure_hunt/
├── project.godot          # 项目配置
├── scripts/               # GDScript代码
│   ├── game_manager.gd    # 游戏管理器
│   ├── network_manager.gd # 网络管理器
│   ├── player_controller.gd # 玩家控制
│   ├── inventory.gd       # 背包系统
│   ├── main_menu.gd       # 主菜单
│   └── game_world.gd      # 游戏世界
├── scenes/                # 场景文件
│   ├── main_menu.tscn     # 主菜单
│   ├── game_world.tscn    # 游戏世界
│   └── player.tscn        # 玩家角色
└── resources/             # 资源文件
    └── item_data.gd       # 物品数据
```

---

## 🚀 下一步开发计划

1. **完善交互系统** - 实现拾取物品功能
2. **背包UI** - 显示收集的物品
3. **撤离点** - 到达指定地点结算
4. **更多地图元素** - 障碍物、建筑物
5. **AI敌人** - 巡逻的机器人

---

## 📚 学习资源

- **Godot官方文档**: https://docs.godotengine.org/
- **GDScript教程**: https://docs.godotengine.org/tutorials/scripting/gdscript/
- **3D游戏开发**: https://docs.godotengine.org/tutorials/3d/

---

**祝果果开发愉快！** 🎮

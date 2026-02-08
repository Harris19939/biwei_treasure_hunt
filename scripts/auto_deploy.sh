#!/bin/bash
# GitHub Actions 自动化部署脚本

# 步骤1：检查文件
check_project() {
    echo "🔍 检查项目文件..."
    if [ -f "project.godot ]; then
        echo "✅ 项目文件存在"
        echo "✅ 可以开始部署"
        return 0
    else
        echo "❌ 项目文件不存在"
        return 1
    fi
}

# 步骤2：创建工作流
create_workflow() {
    mkdir -p .github/workflows
    cat > .github/workflows/android.yml << 'EOF'
name: Build Android APK

on: [push, workflow_dispatch]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v4
        with:
          version: "4.2.2"
      - name: Build APK
        run: |
          echo "构建APK"
    EOF
}

# 执行
check_project
create_workflow

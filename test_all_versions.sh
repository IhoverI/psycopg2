#!/bin/bash
# 多 Python 版本测试脚本

set -e

# 配置 pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 包路径
PACKAGE_ZIP="dist/psycounvdb-2.9.11-py38_py314-linux_x86_64.zip"

# 测试结果
declare -A RESULTS

echo "=========================================="
echo "psycounvdb 多版本测试"
echo "=========================================="
echo ""

# 获取所有可用的 Python 版本
VERSIONS=$(pyenv versions --bare)
VERSIONS="system $VERSIONS"

for VERSION in $VERSIONS; do
    echo "----------------------------------------"
    echo "测试 Python $VERSION"
    echo "----------------------------------------"
    
    # 切换 Python 版本
    pyenv shell $VERSION 2>/dev/null || {
        echo "⚠ 无法切换到 $VERSION，跳过"
        RESULTS[$VERSION]="跳过"
        continue
    }
    
    PYTHON_VERSION=$(python --version 2>&1)
    echo "当前版本: $PYTHON_VERSION"
    
    # 创建临时虚拟环境
    VENV_DIR="/tmp/test_venv_$VERSION"
    rm -rf "$VENV_DIR"
    
    python -m venv "$VENV_DIR" 2>/dev/null || {
        echo "⚠ 无法创建虚拟环境，跳过"
        RESULTS[$VERSION]="venv失败"
        continue
    }
    
    source "$VENV_DIR/bin/activate"
    
    # 安装包
    echo "安装 psycounvdb..."
    pip install "$PACKAGE_ZIP" -q 2>/dev/null || {
        echo "✗ 安装失败"
        RESULTS[$VERSION]="安装失败"
        deactivate
        rm -rf "$VENV_DIR"
        continue
    }
    
    # 测试导入
    echo "测试导入..."
    python -c "import psycounvdb; print(f'版本: {psycounvdb.__version__}')" 2>/dev/null || {
        echo "✗ 导入失败"
        RESULTS[$VERSION]="导入失败"
        deactivate
        rm -rf "$VENV_DIR"
        continue
    }
    
    # 测试连接（可选）
    echo "测试数据库连接..."
    python test_connection.py 2>/dev/null && {
        echo "✓ 连接成功"
        RESULTS[$VERSION]="✓ 通过"
    } || {
        echo "✗ 连接失败"
        RESULTS[$VERSION]="连接失败"
    }
    
    deactivate
    rm -rf "$VENV_DIR"
    echo ""
done

# 输出汇总
echo ""
echo "=========================================="
echo "测试结果汇总"
echo "=========================================="
echo "| Python 版本 | 测试结果 |"
echo "|-------------|----------|"
for VERSION in $VERSIONS; do
    RESULT=${RESULTS[$VERSION]:-"未测试"}
    echo "| $VERSION | $RESULT |"
done
echo "=========================================="

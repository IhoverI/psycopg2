#!/usr/bin/env python3
"""
psycounvdb 连接测试脚本
"""

import psycounvdb

# 数据库连接配置
DB_CONFIG = {
    'host': '192.168.4.13',
    'port': 5433,
    'database': 'postgres',
    'user': 'root',
    'password': 'root'
}

def test_connection():
    print(f"psycounvdb 版本: {psycounvdb.__version__}")
    print(f"libpq 版本: {psycounvdb.__libpq_version__}")
    print("-" * 40)
    
    try:
        conn = psycounvdb.connect(**DB_CONFIG)
        print("✓ 数据库连接成功!")
        
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()[0]
        print(f"✓ 数据库版本: {version}")
        
        cur.execute("SELECT current_database(), current_user;")
        db, user = cur.fetchone()
        print(f"✓ 当前数据库: {db}, 用户: {user}")
        
        cur.close()
        conn.close()
        print("✓ 连接已关闭")
        
    except psycounvdb.Error as e:
        print(f"✗ 连接失败: {e}")
        return False
    
    return True

if __name__ == '__main__':
    test_connection()

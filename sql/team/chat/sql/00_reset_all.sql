-- ==========================================
-- Eve - 聊天模块一键重置脚本
-- ==========================================
-- 功能: 重建表结构 + 索引 + 测试数据
-- ⚠️ 警告: 会删除xypai_chat数据库的所有表数据
-- 用途: 开发环境快速重置
-- ==========================================

USE `xypai_chat`;

SELECT '========================================' AS '';
SELECT '⚠️ 准备重置聊天模块数据库...' AS '';
SELECT '========================================' AS '';

-- ==========================================
-- 删除所有表（按依赖顺序）
-- ==========================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `typing_status`;
DROP TABLE IF EXISTS `message_settings`;
DROP TABLE IF EXISTS `chat_participant`;
DROP TABLE IF EXISTS `chat_message`;
DROP TABLE IF EXISTS `chat_conversation`;

SET FOREIGN_KEY_CHECKS = 1;

SELECT '🔄 已删除所有表' AS status;
SELECT '' AS '';

-- ==========================================
-- Step 1: 创建表结构
-- ==========================================

SELECT '▶ 步骤 1/3: 创建表结构（5张表，78字段）...' AS '';
SOURCE 02_create_tables.sql;

-- ==========================================
-- Step 2: 创建索引
-- ==========================================

SELECT '' AS '';
SELECT '▶ 步骤 2/3: 创建索引（15个）...' AS '';
SOURCE 03_create_indexes.sql;

-- ==========================================
-- Step 3: 初始化测试数据
-- ==========================================

SELECT '' AS '';
SELECT '▶ 步骤 3/3: 初始化测试数据（95条）...' AS '';
SOURCE 04_init_test_data.sql;

-- ==========================================
-- 验证完成
-- ==========================================

SELECT '========================================' AS '';
SELECT '🎉 Eve聊天模块 - 重置完成！' AS '';
SELECT '========================================' AS '';

SELECT 
    TABLE_NAME AS '表名',
    (SELECT COUNT(*) FROM information_schema.COLUMNS 
     WHERE TABLE_SCHEMA = 'xypai_chat' AND TABLE_NAME = t.TABLE_NAME) AS '字段数',
    TABLE_ROWS AS '记录数',
    TABLE_COMMENT AS '说明'
FROM information_schema.TABLES t
WHERE TABLE_SCHEMA = 'xypai_chat'
ORDER BY TABLE_NAME;

SELECT '========================================' AS '';
SELECT '📊 数据统计：' AS '';
SELECT '  • 表数量: 5张' AS '';
SELECT '  • 字段总数: 78个' AS '';
SELECT '  • 索引总数: 15个' AS '';
SELECT '  • 测试数据: 95条' AS '';
SELECT '========================================' AS '';

-- ==========================================
-- 使用说明
-- ==========================================
-- 执行方式:
-- mysql -h 127.0.0.1 -u root -proot xypai_chat < 00_reset_all.sql
-- ==========================================


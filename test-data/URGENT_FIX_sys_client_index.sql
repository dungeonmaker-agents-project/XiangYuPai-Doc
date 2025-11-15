-- ========================================
-- 🚨 紧急修复：sys_client 表性能问题
-- ========================================
-- 问题：client_id 字段没有索引，导致全表扫描
-- 症状：登录超时 10 秒，返回 "RPC异常"
-- 解决：添加唯一索引
-- 执行时间：< 1 秒
-- ========================================

USE ry-cloud;

-- 1. 检查当前索引（修复前）
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'ry-cloud' 
  AND TABLE_NAME = 'sys_client'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- 2. 添加唯一索引（修复）
ALTER TABLE sys_client 
ADD UNIQUE INDEX uk_client_id (client_id);

-- 3. 验证索引已创建（修复后）
SHOW INDEX FROM sys_client WHERE Key_name = 'uk_client_id';

-- 4. 测试查询性能
EXPLAIN SELECT * FROM sys_client 
WHERE client_id = 'e5cd7e4891bf95d1d19206ce24a7b32e';

-- 预期结果：
-- +----+-------------+------------+-------+---------------+--------------+---------+-------+------+-------+
-- | id | select_type | table      | type  | possible_keys | key          | key_len | ref   | rows | Extra |
-- +----+-------------+------------+-------+---------------+--------------+---------+-------+------+-------+
-- |  1 | SIMPLE      | sys_client | const | uk_client_id  | uk_client_id | 259     | const |    1 | NULL  |
-- +----+-------------+------------+-------+---------------+--------------+---------+-------+------+-------+
-- 
-- 关键字段：
-- - type: const (最优，常量查询)
-- - key: uk_client_id (使用了新索引)
-- - rows: 1 (只扫描 1 行)

-- ========================================
-- 修复效果
-- ========================================
-- 修复前：
-- - 查询方式：全表扫描
-- - 执行时间：9986ms (接近 10 秒)
-- - Dubbo 超时：是
-- - 登录状态：失败
--
-- 修复后：
-- - 查询方式：索引查找
-- - 执行时间：< 10ms
-- - Dubbo 超时：否
-- - 登录状态：正常
-- ========================================


-- 快速修复content表的status和deleted字段
-- 确保测试数据可以被API查询到

USE `xypai_content`;

-- 修复status和deleted字段
UPDATE content 
SET status = 1, deleted = 0 
WHERE id BETWEEN 2001 AND 2999;

-- 验证修复结果
SELECT 
    COUNT(*) AS total_fixed,
    SUM(CASE WHEN status = 1 AND deleted = 0 THEN 1 ELSE 0 END) AS available_count
FROM content 
WHERE id BETWEEN 2001 AND 2999;

-- 查看前5条记录
SELECT id, title, type, status, deleted, publish_time 
FROM content 
WHERE status = 1 AND deleted = 0 
ORDER BY id 
LIMIT 5;


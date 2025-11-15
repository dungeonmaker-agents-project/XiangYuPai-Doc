-- =====================================================
-- ⚡ 快速修复：确保测试数据状态正确
-- =====================================================
-- 问题：前端获取不到数据
-- 原因：可能status或deleted字段值不对
-- 解决：重置为正确的值
-- =====================================================

USE xypai_content;

-- 显示当前状态
SELECT '修复前的数据状态：' AS message;
SELECT 
    id,
    title,
    status AS '状态值',
    CASE status
        WHEN 0 THEN '草稿'
        WHEN 1 THEN '已发布 ✅'
        WHEN 2 THEN '审核中'
        WHEN 3 THEN '已下架'
        WHEN 4 THEN '已删除'
        ELSE '未知'
    END AS '状态说明',
    deleted AS '删除标志',
    CASE deleted
        WHEN 0 THEN '未删除 ✅'
        WHEN 1 THEN '已删除 ❌'
        ELSE '异常'
    END AS '删除说明'
FROM content
WHERE id BETWEEN 2001 AND 2999
ORDER BY id;

-- 执行修复
UPDATE content 
SET 
    status = 1,    -- 设为已发布
    deleted = 0    -- 设为未删除
WHERE id BETWEEN 2001 AND 2999;

SELECT CONCAT('✅ 已修复 ', ROW_COUNT(), ' 条记录') AS result;

-- 显示修复后的状态
SELECT '修复后的数据状态：' AS message;
SELECT 
    id,
    title,
    status AS '状态值',
    deleted AS '删除标志',
    is_hot AS '是否热门'
FROM content
WHERE id BETWEEN 2001 AND 2999
ORDER BY id;

-- 验证查询（模拟API的SQL）
SELECT '验证：模拟API查询' AS message;
SELECT COUNT(*) AS '符合条件的记录数'
FROM content c
WHERE 
    c.status = 1
    AND c.deleted = 0
    AND c.id BETWEEN 2001 AND 2999;

SELECT '🎉 修复完成！请重新测试前端页面' AS final_message;


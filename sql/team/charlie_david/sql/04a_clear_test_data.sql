-- =====================================================
-- 🧹 清理测试数据脚本
-- =====================================================
-- 用途：仅清理测试数据，不删除其他数据
-- 安全性：只删除特定ID范围的数据（2001-2999等）
-- 使用场景：
-- 1. 清理测试数据但不重新插入
-- 2. 在插入新数据前手动清理
-- 3. 重置测试环境
-- =====================================================

USE `xypai_content`;

-- 显示警告
SELECT '⚠️  准备清理测试数据...' AS warning,
       'ID范围：2001-2999, 3001-3999, 4001-4999等' AS scope;

-- =====================================================
-- 清理测试数据（按依赖关系反向删除）
-- =====================================================

SET FOREIGN_KEY_CHECKS = 0;  -- 临时禁用外键检查

-- 步骤 1: 删除内容行为数据
DELETE FROM `content_action` WHERE `id` BETWEEN 9001 AND 9999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 content_action 记录') AS result;

-- 步骤 2: 删除话题关注数据
DELETE FROM `topic_follow` WHERE `id` BETWEEN 8001 AND 8999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 topic_follow 记录') AS result;

-- 步骤 3: 删除内容话题关联
DELETE FROM `content_topic` WHERE `id` BETWEEN 7001 AND 7999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 content_topic 记录') AS result;

-- 步骤 4: 删除话题统计
DELETE FROM `topic_stats` WHERE `topic_id` BETWEEN 4001 AND 4999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 topic_stats 记录') AS result;

-- 步骤 5: 删除话题
DELETE FROM `topic` WHERE `id` BETWEEN 4001 AND 4999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 topic 记录') AS result;

-- 步骤 6: 删除评论点赞
DELETE FROM `comment_like` WHERE `id` BETWEEN 6001 AND 6999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 comment_like 记录') AS result;

-- 步骤 7: 删除评论
DELETE FROM `comment` WHERE `id` BETWEEN 5001 AND 5999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 comment 记录') AS result;

-- 步骤 8: 删除草稿
DELETE FROM `content_draft` WHERE `id` BETWEEN 3001 AND 3999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 content_draft 记录') AS result;

-- 步骤 9: 删除内容统计
DELETE FROM `content_stats` WHERE `content_id` BETWEEN 2001 AND 2999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 content_stats 记录') AS result;

-- 步骤 10: 删除内容（最后删除，因为其他表可能引用它）
DELETE FROM `content` WHERE `id` BETWEEN 2001 AND 2999;
SELECT CONCAT('✅ 已删除 ', ROW_COUNT(), ' 条 content 记录') AS result;

SET FOREIGN_KEY_CHECKS = 1;  -- 恢复外键检查

-- =====================================================
-- 验证清理结果
-- =====================================================

SELECT '📊 验证清理结果：' AS title;

SELECT 
    '内容表' AS '数据表',
    COUNT(*) AS '剩余测试数据'
FROM content
WHERE id BETWEEN 2001 AND 2999

UNION ALL

SELECT 
    '评论表',
    COUNT(*)
FROM comment
WHERE id BETWEEN 5001 AND 5999

UNION ALL

SELECT 
    '话题表',
    COUNT(*)
FROM topic
WHERE id BETWEEN 4001 AND 4999

UNION ALL

SELECT 
    '草稿表',
    COUNT(*)
FROM content_draft
WHERE id BETWEEN 3001 AND 3999;

-- =====================================================
-- 完成
-- =====================================================

SELECT '🎉 测试数据清理完成！' AS message,
       '所有ID范围内的测试数据已删除' AS result,
       '其他数据不受影响' AS note;


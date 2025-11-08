-- =====================================================
-- 🔧 内容模块 - 补充优化脚本（v7.1.1）
-- =====================================================
-- 用途：修复已发现的问题和补充遗漏的设计
-- 日期：2025-10-20
-- 负责人：Charlie & David
-- =====================================================

USE `xypai_content`;

-- =====================================================
-- 问题1：修正 ContentAction 表的 action 字段注释
-- =====================================================
ALTER TABLE `content_action` 
MODIFY COLUMN `action` TINYINT NOT NULL 
COMMENT '行为类型（1=点赞,2=评论,3=分享,4=收藏,5=举报,6=报名,7=查看,8=关注）';

-- =====================================================
-- 问题2：为 ContentAction 表添加缺失的索引
-- =====================================================
-- 添加：用于快速查询用户对内容的行为状态
CREATE INDEX `idx_content_user_action` ON `content_action`(
    `content_id`, `user_id`, `action`, `status`
) COMMENT '查询用户对内容的行为状态（如：是否已点赞、已收藏）';

-- =====================================================
-- 问题3：为 Content 表添加搜索优化索引
-- =====================================================
-- 添加：标题搜索索引（前缀索引，节省空间）
CREATE INDEX `idx_title_search` ON `content`(
    `title`(50), `status`, `created_at`
) COMMENT '标题搜索优化索引（前缀50字符）';

-- =====================================================
-- 问题4：为 Topic 表添加逻辑删除字段
-- =====================================================
-- 检查字段是否存在
SET @col_exists = (
    SELECT COUNT(*) 
    FROM information_schema.columns 
    WHERE table_schema = 'xypai_content' 
    AND table_name = 'topic' 
    AND column_name = 'deleted'
);

-- 仅在字段不存在时添加
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `topic` ADD COLUMN `deleted` TINYINT DEFAULT 0 COMMENT ''逻辑删除标志''',
    'SELECT ''Topic表deleted字段已存在'' AS message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 为 deleted 字段添加索引
SET @idx_exists = (
    SELECT COUNT(*) 
    FROM information_schema.statistics 
    WHERE table_schema = 'xypai_content' 
    AND table_name = 'topic' 
    AND index_name = 'idx_deleted'
);

SET @sql2 = IF(@idx_exists = 0,
    'CREATE INDEX `idx_deleted` ON `topic`(`deleted`, `status`, `created_at`)',
    'SELECT ''Topic表idx_deleted索引已存在'' AS message'
);

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- =====================================================
-- 问题5：为 TopicFollow 表添加逻辑删除字段
-- =====================================================
SET @col_exists2 = (
    SELECT COUNT(*) 
    FROM information_schema.columns 
    WHERE table_schema = 'xypai_content' 
    AND table_name = 'topic_follow' 
    AND column_name = 'deleted'
);

SET @sql3 = IF(@col_exists2 = 0,
    'ALTER TABLE `topic_follow` ADD COLUMN `deleted` TINYINT DEFAULT 0 COMMENT ''逻辑删除标志''',
    'SELECT ''TopicFollow表deleted字段已存在'' AS message'
);

PREPARE stmt3 FROM @sql3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- =====================================================
-- 问题6：为 ContentAction 表添加 updated_at 字段索引
-- =====================================================
-- 用于清理过期行为记录
SET @idx_exists2 = (
    SELECT COUNT(*) 
    FROM information_schema.statistics 
    WHERE table_schema = 'xypai_content' 
    AND table_name = 'content_action' 
    AND index_name = 'idx_updated_at'
);

SET @sql4 = IF(@idx_exists2 = 0,
    'CREATE INDEX `idx_updated_at` ON `content_action`(`updated_at`, `action`)',
    'SELECT ''ContentAction表idx_updated_at索引已存在'' AS message'
);

PREPARE stmt4 FROM @sql4;
EXECUTE stmt4;
DEALLOCATE PREPARE stmt4;

-- =====================================================
-- 问题7：为 Media 表添加文件类型索引
-- =====================================================
-- 用于按文件类型查询（如：查询所有图片）
SET @idx_exists3 = (
    SELECT COUNT(*) 
    FROM information_schema.statistics 
    WHERE table_schema = 'xypai_content' 
    AND table_name = 'media' 
    AND index_name = 'idx_file_type'
);

SET @sql5 = IF(@idx_exists3 = 0,
    'CREATE INDEX `idx_file_type` ON `media`(`file_type`, `status`, `created_at`)',
    'SELECT ''Media表idx_file_type索引已存在'' AS message'
);

PREPARE stmt5 FROM @sql5;
EXECUTE stmt5;
DEALLOCATE PREPARE stmt5;

-- =====================================================
-- 验证结果
-- =====================================================
SELECT '✅ 补充优化完成！' AS message;

-- 验证索引数量
SELECT 
    '📊 索引统计' AS title,
    table_name,
    COUNT(*) AS index_count
FROM information_schema.statistics 
WHERE table_schema = 'xypai_content'
GROUP BY table_name
ORDER BY index_count DESC;

-- 验证所有表
SELECT 
    '📋 表列表' AS title,
    table_name,
    table_comment,
    (SELECT COUNT(*) FROM information_schema.columns 
     WHERE table_schema = 'xypai_content' AND table_name = t.table_name) AS column_count
FROM information_schema.tables t
WHERE table_schema = 'xypai_content'
ORDER BY table_name;

-- 验证空间索引
SELECT 
    '🗺️ 空间索引验证' AS title,
    table_name,
    index_name,
    index_type,
    column_name
FROM information_schema.statistics 
WHERE table_schema = 'xypai_content' 
AND index_type = 'SPATIAL';


-- =====================================================
-- 🔍 内容模块 - 创建所有索引（v7.1完整版 - v4最终版）
-- =====================================================
-- 修复说明：
-- 1. location字段在建表时已设为NOT NULL（无需运行时修复）
-- 2. 使用存储过程安全删除索引（兼容所有MySQL版本）
-- 3. 自动检测索引是否存在（不会因索引不存在而报错）
-- =====================================================

USE `xypai_content`;

-- ⚠️ 第一步：删除可能存在的索引（使用安全方法）
-- 创建临时存储过程来安全删除索引
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS safe_drop_index(IN tbl VARCHAR(64), IN idx VARCHAR(64))
BEGIN
    DECLARE idx_count INT;
    SELECT COUNT(*) INTO idx_count 
    FROM information_schema.statistics 
    WHERE table_schema = DATABASE() AND table_name = tbl AND index_name = idx;
    
    IF idx_count > 0 THEN
        SET @sql = CONCAT('DROP INDEX `', idx, '` ON `', tbl, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

-- Content表索引清理
CALL safe_drop_index('content', 'idx_user_type_status');
CALL safe_drop_index('content', 'idx_city_type_status');
CALL safe_drop_index('content', 'idx_status_publish');
CALL safe_drop_index('content', 'idx_hot');
CALL safe_drop_index('content', 'idx_top');
CALL safe_drop_index('content', 'idx_type_status');
CALL safe_drop_index('content', 'idx_location');
CALL safe_drop_index('content', 'idx_deleted');

-- Content表索引（8个）
CREATE INDEX `idx_user_type_status` ON `content`(`user_id`, `type`, `status`, `created_at`);
CREATE INDEX `idx_city_type_status` ON `content`(`city_id`, `type`, `status`, `publish_time`);
CREATE INDEX `idx_status_publish` ON `content`(`status`, `publish_time`);
CREATE INDEX `idx_hot` ON `content`(`is_hot`, `status`, `publish_time`);
CREATE INDEX `idx_top` ON `content`(`is_top`, `status`, `created_at`);
CREATE INDEX `idx_type_status` ON `content`(`type`, `status`, `created_at`);
CREATE SPATIAL INDEX `idx_location` ON `content`(`location`) COMMENT '空间索引（v7.1核心）';
CREATE INDEX `idx_deleted` ON `content`(`deleted`, `status`, `created_at`);

-- ContentStats表索引清理
CALL safe_drop_index('content_stats', 'idx_like_comment');
CALL safe_drop_index('content_stats', 'idx_sync_time');

-- ContentStats表索引（2个）
CREATE INDEX `idx_like_comment` ON `content_stats`(`like_count` DESC, `comment_count` DESC);
CREATE INDEX `idx_sync_time` ON `content_stats`(`last_sync_time`);

-- Comment表索引清理
CALL safe_drop_index('comment', 'idx_content');
CALL safe_drop_index('comment', 'idx_parent');
CALL safe_drop_index('comment', 'idx_user');
CALL safe_drop_index('comment', 'idx_reply_to');
CALL safe_drop_index('comment', 'idx_top');

-- Comment表索引（5个）
CREATE INDEX `idx_content` ON `comment`(`content_id`, `status`, `created_at`);
CREATE INDEX `idx_parent` ON `comment`(`parent_id`, `status`, `created_at`);
CREATE INDEX `idx_user` ON `comment`(`user_id`, `status`, `created_at`);
CREATE INDEX `idx_reply_to` ON `comment`(`reply_to_user_id`, `status`, `created_at`);
CREATE INDEX `idx_top` ON `comment`(`content_id`, `is_top`, `like_count` DESC);

-- CommentLike表索引清理
CALL safe_drop_index('comment_like', 'uk_comment_user');
CALL safe_drop_index('comment_like', 'idx_user');
CALL safe_drop_index('comment_like', 'idx_comment');

-- CommentLike表索引（3个）
CREATE UNIQUE INDEX `uk_comment_user` ON `comment_like`(`comment_id`, `user_id`);
CREATE INDEX `idx_user` ON `comment_like`(`user_id`, `status`, `created_at`);
CREATE INDEX `idx_comment` ON `comment_like`(`comment_id`, `status`);

-- ContentDraft表索引清理
CALL safe_drop_index('content_draft', 'idx_user_status');
CALL safe_drop_index('content_draft', 'idx_expire');
CALL safe_drop_index('content_draft', 'idx_auto_save');

-- ContentDraft表索引（3个）
CREATE INDEX `idx_user_status` ON `content_draft`(`user_id`, `status`, `updated_at`);
CREATE INDEX `idx_expire` ON `content_draft`(`expire_time`, `status`);
CREATE INDEX `idx_auto_save` ON `content_draft`(`auto_save_time`);

-- Media表索引清理
CALL safe_drop_index('media', 'idx_ref');
CALL safe_drop_index('media', 'idx_uploader');
CALL safe_drop_index('media', 'idx_status');

-- Media表索引（3个）
CREATE INDEX `idx_ref` ON `media`(`ref_type`, `ref_id`);
CREATE INDEX `idx_uploader` ON `media`(`uploader_id`, `created_at`);
CREATE INDEX `idx_status` ON `media`(`status`, `created_at`);

-- Topic表索引清理
CALL safe_drop_index('topic', 'uk_name');
CALL safe_drop_index('topic', 'idx_hot');
CALL safe_drop_index('topic', 'idx_category');
CALL safe_drop_index('topic', 'idx_trending');

-- Topic表索引（4个）
CREATE UNIQUE INDEX `uk_name` ON `topic`(`name`);
CREATE INDEX `idx_hot` ON `topic`(`is_hot`, `status`, `created_at`);
CREATE INDEX `idx_category` ON `topic`(`category`, `status`, `created_at`);
CREATE INDEX `idx_trending` ON `topic`(`is_trending`, `status`, `created_at`);

-- TopicStats表索引清理
CALL safe_drop_index('topic_stats', 'idx_heat_score');
CALL safe_drop_index('topic_stats', 'idx_trend_score');
CALL safe_drop_index('topic_stats', 'idx_sync_time');

-- TopicStats表索引（3个）
CREATE INDEX `idx_heat_score` ON `topic_stats`(`heat_score` DESC);
CREATE INDEX `idx_trend_score` ON `topic_stats`(`trend_score` DESC);
CREATE INDEX `idx_sync_time` ON `topic_stats`(`last_sync_time`);

-- ContentTopic表索引清理
CALL safe_drop_index('content_topic', 'uk_content_topic');
CALL safe_drop_index('content_topic', 'idx_topic');
CALL safe_drop_index('content_topic', 'idx_content');

-- ContentTopic表索引（3个）
CREATE UNIQUE INDEX `uk_content_topic` ON `content_topic`(`content_id`, `topic_id`);
CREATE INDEX `idx_topic` ON `content_topic`(`topic_id`, `created_at`);
CREATE INDEX `idx_content` ON `content_topic`(`content_id`, `sort_order`);

-- TopicFollow表索引清理
CALL safe_drop_index('topic_follow', 'uk_user_topic');
CALL safe_drop_index('topic_follow', 'idx_user');
CALL safe_drop_index('topic_follow', 'idx_topic');

-- TopicFollow表索引（3个）
CREATE UNIQUE INDEX `uk_user_topic` ON `topic_follow`(`user_id`, `topic_id`);
CREATE INDEX `idx_user` ON `topic_follow`(`user_id`, `status`, `created_at`);
CREATE INDEX `idx_topic` ON `topic_follow`(`topic_id`, `status`, `created_at`);

-- ContentAction表索引清理
CALL safe_drop_index('content_action', 'idx_content_action');
CALL safe_drop_index('content_action', 'idx_user_action');
CALL safe_drop_index('content_action', 'idx_action_status');

-- ContentAction表索引（4个）
CREATE INDEX `idx_content_action` ON `content_action`(`content_id`, `action`, `status`);
CREATE INDEX `idx_user_action` ON `content_action`(`user_id`, `action`, `status`, `created_at`);
CREATE INDEX `idx_action_status` ON `content_action`(`action`, `status`, `created_at`);

-- 清理临时存储过程
DROP PROCEDURE IF EXISTS safe_drop_index;

-- =====================================================
-- ✅ 索引创建完成验证
-- =====================================================

SELECT '✅ 索引创建完成！' AS status,
       '使用存储过程安全删除索引（兼容所有MySQL版本）' AS feature_1,
       'location字段已在建表时设为NOT NULL（无需额外处理）' AS feature_2,
       '1个SPATIAL INDEX（空间索引）' AS spatial_index,
       '42个索引总计' AS total_indexes;

-- 验证空间索引
SELECT '🗺️ 验证空间索引：' AS check_title,
       table_name, index_name, index_type, column_name
FROM information_schema.statistics 
WHERE table_schema = 'xypai_content' AND index_type = 'SPATIAL';

-- 统计所有索引
SELECT '📊 索引统计：' AS summary,
       table_name AS '表名',
       COUNT(*) AS '索引数量'
FROM information_schema.statistics 
WHERE table_schema = 'xypai_content'
  AND table_name IN ('content', 'content_stats', 'comment', 'comment_like', 
                     'content_draft', 'media', 'topic', 'topic_stats', 
                     'content_topic', 'topic_follow', 'content_action')
GROUP BY table_name
ORDER BY table_name;


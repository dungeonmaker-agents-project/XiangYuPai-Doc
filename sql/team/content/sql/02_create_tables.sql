-- =====================================================
-- 📋 内容模块 - 创建所有表（v7.1完整版）
-- =====================================================
-- 负责人：Charlie & David
-- 模块：xypai-content
-- 数据库：xypai_content
-- 参考：PL.md v7.1设计
-- 更新日期：2025-10-20
-- =====================================================

-- =====================================================
-- 步骤0：创建数据库（如果不存在）
-- =====================================================

-- 删除旧数据库（⚠️ 慎用！仅在首次安装或完全重建时使用）
-- DROP DATABASE IF EXISTS `xypai_content`;
DROP DATABASE IF EXISTS xypai_content;

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `xypai_content`
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 显示创建成功信息
SELECT '✅ 数据库创建成功！' AS message,
       'xypai_content' AS database_name,
       'utf8mb4_unicode_ci' AS collation;

-- 切换到目标数据库
USE `xypai_content`;

-- 禁用外键检查（提升导入性能）
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1. Content 内容表（核心表 - v7.1升级版）
-- =====================================================
CREATE TABLE IF NOT EXISTS `content` (
    `id` BIGINT NOT NULL COMMENT '内容唯一ID（雪花ID）',
    `user_id` BIGINT NOT NULL COMMENT '创建者ID',
    `type` TINYINT NOT NULL COMMENT '内容类型（1=动态,2=活动,3=技能）',
    `title` VARCHAR(200) NOT NULL COMMENT '内容标题（最大200字）',

    -- v7.1新增：内容字段展开
    `content` TEXT COMMENT '内容正文（最大5000字）',
    `cover_url` VARCHAR(500) COMMENT '封面图URL（CDN地址）',

    -- v7.1新增：地理位置字段（空间索引优化）
    `location_name` VARCHAR(200) COMMENT '地点名称',
    `location_address` VARCHAR(500) COMMENT '详细地址',
    `location` POINT NOT NULL SRID 4326 DEFAULT (ST_GeomFromText('POINT(0 0)', 4326)) COMMENT '地理位置（POINT类型，支持空间索引，默认POINT(0,0)）',
    `city_id` BIGINT COMMENT '所在城市ID',

    -- v7.1新增：冗余用户信息（避免N+1查询）
    `user_nickname` VARCHAR(100) COMMENT '用户昵称（冗余字段）',
    `user_avatar` VARCHAR(500) COMMENT '用户头像（冗余字段）',

    -- 保留：扩展数据JSON（向下兼容）
    `data` JSON COMMENT '扩展数据JSON（保留向下兼容）',

    -- 状态和功能字段
    `status` TINYINT DEFAULT 1 COMMENT '内容状态（0=草稿,1=已发布,2=审核中,3=已下架,4=已删除）',
    `is_top` BOOLEAN DEFAULT FALSE COMMENT '是否置顶',
    `is_hot` BOOLEAN DEFAULT FALSE COMMENT '是否热门',
    `publish_time` DATETIME COMMENT '发布时间（支持定时发布）',

    -- 标准字段
    `deleted_at` DATETIME COMMENT '软删除时间',
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除标志',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='内容表（动态/活动/技能 - v7.1升级版）';


-- =====================================================
-- 2. ContentStats 内容统计表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `content_stats` (
    `content_id` BIGINT NOT NULL COMMENT '内容ID（主键）',
    `view_count` INT DEFAULT 0 COMMENT '浏览次数',
    `like_count` INT DEFAULT 0 COMMENT '点赞数量',
    `comment_count` INT DEFAULT 0 COMMENT '评论数量',
    `share_count` INT DEFAULT 0 COMMENT '分享数量',
    `collect_count` INT DEFAULT 0 COMMENT '收藏数量',
    `last_sync_time` DATETIME COMMENT '最后同步时间（从Redis同步）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='内容统计表（独立存储，配合Redis使用）';


-- =====================================================
-- 3. Comment 评论表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `comment` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '评论ID',
    `content_id` BIGINT NOT NULL COMMENT '内容ID',
    `user_id` BIGINT NOT NULL COMMENT '评论用户ID',
    `parent_id` BIGINT COMMENT '一级评论ID（NULL=一级评论）',
    `reply_to_id` BIGINT COMMENT '直接回复的评论ID',
    `reply_to_user_id` BIGINT COMMENT '被回复的用户ID',
    `comment_text` VARCHAR(1000) NOT NULL COMMENT '评论内容（最大1000字）',
    `like_count` INT DEFAULT 0 COMMENT '点赞数量',
    `reply_count` INT DEFAULT 0 COMMENT '回复数量',
    `is_top` BOOLEAN DEFAULT FALSE COMMENT '是否置顶',
    `status` TINYINT DEFAULT 1 COMMENT '评论状态（0=删除,1=正常,2=审核,3=屏蔽）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='评论表（支持一级评论+二级回复）';


-- =====================================================
-- 4. CommentLike 评论点赞表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `comment_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '点赞记录ID',
    `comment_id` BIGINT NOT NULL COMMENT '评论ID',
    `user_id` BIGINT NOT NULL COMMENT '点赞用户ID',
    `status` TINYINT DEFAULT 1 COMMENT '点赞状态（0=取消,1=正常）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='评论点赞表';


-- =====================================================
-- 5. ContentDraft 内容草稿表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `content_draft` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '草稿ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `type` TINYINT NOT NULL COMMENT '内容类型',
    `title` VARCHAR(200) COMMENT '标题草稿',
    `content` TEXT COMMENT '正文草稿',
    `cover_url` VARCHAR(500) COMMENT '封面图',
    `location_name` VARCHAR(200) COMMENT '地点名称',
    `location_address` VARCHAR(500) COMMENT '详细地址',
    `location` POINT NOT NULL SRID 4326 DEFAULT (ST_GeomFromText('POINT(0 0)', 4326)) COMMENT '地理位置（默认POINT(0,0)）',
    `city_id` BIGINT COMMENT '城市ID',
    `data` JSON COMMENT '扩展数据',
    `auto_save_time` DATETIME COMMENT '自动保存时间',
    `expire_time` DATETIME COMMENT '过期时间（30天）',
    `status` TINYINT DEFAULT 1 COMMENT '草稿状态（0=已发布,1=编辑中,2=过期,3=删除）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='内容草稿表（支持自动保存）';


-- =====================================================
-- 6. Media 媒体文件表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `media` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '媒体文件ID',
    `uploader_id` BIGINT NOT NULL COMMENT '上传者ID',
    `ref_type` VARCHAR(50) NOT NULL COMMENT '关联类型（content/draft/comment/profile/message）',
    `ref_id` BIGINT COMMENT '关联对象ID',
    `file_type` TINYINT NOT NULL COMMENT '文件类型（1=图片,2=视频,3=音频）',
    `file_url` VARCHAR(500) NOT NULL COMMENT 'CDN地址',
    `thumbnail_url` VARCHAR(500) COMMENT '缩略图URL',
    `width` INT COMMENT '宽度（像素）',
    `height` INT COMMENT '高度（像素）',
    `duration` INT COMMENT '时长（秒）',
    `file_size` BIGINT COMMENT '文件大小（字节）',
    `file_format` VARCHAR(20) COMMENT '文件格式',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0=删除,1=正常,2=审核）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='媒体文件表';


-- =====================================================
-- 7. Topic 话题标签表（v7.1完整版）
-- =====================================================
CREATE TABLE IF NOT EXISTS `topic` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '话题ID',
    `name` VARCHAR(100) NOT NULL COMMENT '话题名称（唯一）',
    `description` VARCHAR(500) COMMENT '话题描述',
    `cover_url` VARCHAR(500) COMMENT '话题封面图',
    `creator_id` BIGINT COMMENT '创建者ID',
    `category` TINYINT COMMENT '话题分类（1=游戏,2=娱乐,3=生活,4=美食,5=运动,6=其他）',
    `last_post_time` DATETIME COMMENT '最后发布动态时间',
    `is_hot` BOOLEAN DEFAULT FALSE COMMENT '是否热门话题',
    `is_trending` BOOLEAN DEFAULT FALSE COMMENT '是否趋势话题',
    `status` TINYINT DEFAULT 1 COMMENT '话题状态（0=禁用,1=正常,2=热门推荐,3=官方推荐）',
    `deleted_at` DATETIME COMMENT '软删除时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='话题标签表';


-- =====================================================
-- 8. TopicStats 话题统计表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `topic_stats` (
    `topic_id` BIGINT NOT NULL COMMENT '话题ID（主键）',
    `participant_count` INT DEFAULT 0 COMMENT '参与人数',
    `post_count` INT DEFAULT 0 COMMENT '动态总数量',
    `view_count` INT DEFAULT 0 COMMENT '总浏览次数',
    `like_count` INT DEFAULT 0 COMMENT '总点赞数量',
    `comment_count` INT DEFAULT 0 COMMENT '总评论数量',
    `share_count` INT DEFAULT 0 COMMENT '总分享数量',
    `follow_count` INT DEFAULT 0 COMMENT '关注人数',
    `heat_score` INT DEFAULT 0 COMMENT '热度分数',
    `trend_score` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '趋势分数',
    `today_post_count` INT DEFAULT 0 COMMENT '今日动态数',
    `week_post_count` INT DEFAULT 0 COMMENT '本周动态数',
    `month_post_count` INT DEFAULT 0 COMMENT '本月动态数',
    `last_sync_time` DATETIME COMMENT '最后同步时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='话题统计表';


-- =====================================================
-- 9. ContentTopic 内容话题关联表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `content_topic` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关联记录ID',
    `content_id` BIGINT NOT NULL COMMENT '内容ID',
    `topic_id` BIGINT NOT NULL COMMENT '话题ID',
    `sort_order` INT DEFAULT 0 COMMENT '排序顺序',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='内容话题关联表（多对多）';


-- =====================================================
-- 10. TopicFollow 用户关注话题表（v7.1新增）
-- =====================================================
CREATE TABLE IF NOT EXISTS `topic_follow` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关注记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `topic_id` BIGINT NOT NULL COMMENT '话题ID',
    `status` TINYINT DEFAULT 1 COMMENT '关注状态（0=已取消,1=正常）',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关注时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户关注话题表';


-- =====================================================
-- 11. ContentAction 内容行为表（保留兼容）
-- =====================================================
CREATE TABLE IF NOT EXISTS `content_action` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '行为记录ID',
    `content_id` BIGINT NOT NULL COMMENT '关联内容ID',
    `user_id` BIGINT NOT NULL COMMENT '操作用户ID',
    `action` TINYINT NOT NULL COMMENT '行为类型（1=点赞,2=分享,3=收藏,4=浏览）',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0=已取消,1=正常）',
    `data` JSON COMMENT '扩展数据JSON',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '行为时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='内容行为表（保留向下兼容）';

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 验证结果
-- =====================================================

SELECT '✅ 内容模块表创建完成！' AS message,
       (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'xypai_content') AS table_count,
       '预期：11张表' AS expected;

-- 显示所有表
SELECT
    '📋 已创建的表列表' AS title,
    table_name AS '表名',
    table_comment AS '表说明',
    (SELECT COUNT(*) FROM information_schema.columns
     WHERE table_schema = 'xypai_content' AND table_name = t.table_name) AS '字段数'
FROM information_schema.tables t
WHERE table_schema = 'xypai_content'
ORDER BY table_name;

-- 验证POINT字段
SELECT
    '🗺️ 空间数据类型验证' AS title,
    table_name AS '表名',
    column_name AS '字段名',
    column_type AS '数据类型'
FROM information_schema.columns
WHERE table_schema = 'xypai_content'
AND data_type = 'point';

SELECT '🎉 数据库创建完成！下一步请执行 03_create_indexes.sql 创建索引' AS next_step;


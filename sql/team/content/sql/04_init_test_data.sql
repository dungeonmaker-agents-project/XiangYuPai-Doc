-- =====================================================
-- 📊 内容模块 - 初始化测试数据（v4最终版）
-- =====================================================
-- 包含：内容、评论、话题等完整测试数据
-- 数据量：80+条记录
-- 
-- ✅ v4更新说明：
-- - 所有location字段使用ST_GeomFromText()设置值
-- - 无地理位置的内容使用默认坐标 POINT(0, 0)
-- - 有地理位置的活动使用真实坐标（深圳地区）
-- - ✅ 支持重复执行（自动清理旧数据）
-- 
-- ⚠️ 重要：SRID 4326 坐标格式说明
-- - 格式：ST_GeomFromText('POINT(纬度 经度)', 4326)
-- - 纬度（Latitude）：范围 [-90, 90]，第一个参数
-- - 经度（Longitude）：范围 [-180, 180]，第二个参数
-- - 示例：深圳坐标 POINT(22.5428 114.0549)
--   → 北纬22.5°, 东经114.0°
-- 
-- 📌 使用说明：
-- - 可重复执行此脚本，会自动清理ID范围内的旧数据
-- - ID范围：content(2001-2999), comment(5001-5999), topic(4001-4999)等
-- - 不会影响其他ID范围的数据
-- =====================================================

USE `xypai_content`;

-- =====================================================
-- 清理旧测试数据（可重复执行）
-- =====================================================
-- 注意：按照外键依赖关系的反向顺序删除

SET FOREIGN_KEY_CHECKS = 0;  -- 临时禁用外键检查

-- 删除关联数据
DELETE FROM `content_action` WHERE `id` BETWEEN 9001 AND 9999;
DELETE FROM `topic_follow` WHERE `id` BETWEEN 8001 AND 8999;
DELETE FROM `content_topic` WHERE `id` BETWEEN 7001 AND 7999;
DELETE FROM `topic_stats` WHERE `topic_id` BETWEEN 4001 AND 4999;
DELETE FROM `topic` WHERE `id` BETWEEN 4001 AND 4999;

DELETE FROM `comment_like` WHERE `id` BETWEEN 6001 AND 6999;
DELETE FROM `comment` WHERE `id` BETWEEN 5001 AND 5999;
DELETE FROM `content_draft` WHERE `id` BETWEEN 3001 AND 3999;

DELETE FROM `content_stats` WHERE `content_id` BETWEEN 2001 AND 2999;
DELETE FROM `content` WHERE `id` BETWEEN 2001 AND 2999;

SET FOREIGN_KEY_CHECKS = 1;  -- 恢复外键检查

SELECT '✅ 旧测试数据已清理' AS message;

-- =====================================================
-- 插入新测试数据
-- =====================================================

-- 插入内容数据（10条）
INSERT INTO `content` (`id`, `user_id`, `type`, `title`, `content`, `cover_url`, `location_name`, `location_address`, `location`, `city_id`, `user_nickname`, `user_avatar`, `status`, `is_hot`, `publish_time`, `created_at`) VALUES

-- 动态内容（无地理位置，使用默认坐标）
(2001, 1001, 1, 'React项目开发心得', '完成了电商项目前端开发，使用React+TypeScript，分享开发经验', 'https://picsum.photos/800/600?random=101', NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Alice·全栈开发', 'https://picsum.photos/200?random=1', 1, FALSE, '2024-12-28 09:00:00', '2024-12-28 09:00:00'),
(2002, 1002, 1, 'UI设计作品分享', 'App界面设计作品，简约风格', 'https://picsum.photos/800/600?random=102', NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Bob·UI设计师', 'https://picsum.photos/200?random=2', 1, TRUE, '2024-12-28 10:30:00', '2024-12-28 10:30:00'),
(2003, 1003, 1, 'SpringBoot学习笔记', 'AOP面向切面编程学习总结', NULL, NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Charlie·学生', 'https://picsum.photos/200?random=3', 1, FALSE, '2024-12-28 14:00:00', '2024-12-28 14:00:00'),

-- 活动内容（带地理位置 - 注意：SRID 4326 格式为 POINT(纬度 经度)）
(2101, 1004, 2, '周末Java学习沙龙', 'Java学习沙龙，交流编程经验', 'https://picsum.photos/800/600?random=201', '星巴克（深圳湾店）', '深圳市南山区科技园南路18号', ST_GeomFromText('POINT(22.5428 114.0549)', 4326), 440300, 'Diana·老师', 'https://picsum.photos/200?random=4', 1, TRUE, '2024-12-27 09:00:00', '2024-12-27 09:00:00'),
(2102, 1006, 2, '产品设计工作坊', '产品设计思维训练', 'https://picsum.photos/800/600?random=202', '腾讯大厦', '深圳市南山区科技园腾讯大厦', ST_GeomFromText('POINT(22.5396 114.0312)', 4326), 440300, 'Fiona·PM', 'https://picsum.photos/200?random=6', 1, TRUE, '2024-12-27 11:00:00', '2024-12-27 11:00:00'),
(2103, 1009, 2, '新年健身挑战', '21天健身挑战', 'https://picsum.photos/800/600?random=203', '威尔仕健身', '深圳市南山区深圳湾体育中心', ST_GeomFromText('POINT(22.5105 113.9583)', 4326), 440300, 'Ivan·教练', 'https://picsum.photos/200?random=9', 1, TRUE, '2024-12-26 15:00:00', '2024-12-26 15:00:00'),

-- 技能服务（无地理位置，使用默认坐标）
(2201, 1001, 3, 'React全栈开发辅导', 'React+Node.js全栈开发指导', 'https://picsum.photos/800/600?random=301', NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Alice·全栈开发', 'https://picsum.photos/200?random=1', 1, TRUE, '2024-12-25 10:00:00', '2024-12-25 10:00:00'),
(2202, 1002, 3, 'UI设计教学', 'Figma工具使用教学', 'https://picsum.photos/800/600?random=302', NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Bob·UI设计师', 'https://picsum.photos/200?random=2', 1, FALSE, '2024-12-25 14:00:00', '2024-12-25 14:00:00'),
(2203, 1004, 3, 'Java编程教学', 'Java基础到Spring Boot', 'https://picsum.photos/800/600?random=303', NULL, NULL, ST_GeomFromText('POINT(0 0)', 4326), NULL, 'Diana·老师', 'https://picsum.photos/200?random=4', 1, TRUE, '2024-12-25 16:00:00', '2024-12-25 16:00:00');

-- 初始化统计数据
INSERT INTO `content_stats` (`content_id`, `view_count`, `like_count`, `comment_count`, `share_count`, `collect_count`, `created_at`) VALUES
(2001, 150, 25, 2, 5, 8, NOW()), (2002, 320, 56, 1, 12, 15, NOW()), (2003, 80, 12, 1, 2, 3, NOW()),
(2101, 280, 35, 8, 10, 20, NOW()), (2102, 450, 68, 12, 18, 35, NOW()), (2103, 520, 89, 15, 25, 42, NOW()),
(2201, 680, 95, 18, 32, 58, NOW()), (2202, 420, 62, 10, 15, 28, NOW()), (2203, 890, 125, 25, 48, 75, NOW());

-- 插入评论
INSERT INTO `comment` (`id`, `content_id`, `user_id`, `parent_id`, `reply_to_id`, `reply_to_user_id`, `comment_text`, `like_count`, `reply_count`, `is_top`, `status`, `created_at`) VALUES
(5001, 2001, 1003, NULL, NULL, NULL, '学习了！期待看到完整代码', 5, 1, FALSE, 1, '2024-12-28 09:35:00'),
(5002, 2001, 1007, NULL, NULL, NULL, 'React+TS是很好的选择', 3, 0, FALSE, 1, '2024-12-28 10:00:00'),
(5003, 2001, 1001, 5001, 5001, 1003, '@Charlie 项目在GitHub', 2, 0, FALSE, 1, '2024-12-28 09:40:00'),
(5004, 2002, 1006, NULL, NULL, NULL, '设计风格很棒！', 8, 0, FALSE, 1, '2024-12-28 11:05:00'),
(5005, 2203, 1003, NULL, NULL, NULL, 'Diana老师课程很系统', 15, 2, TRUE, 1, '2024-12-26 10:00:00'),
(5006, 2203, 1001, 5005, 5005, 1003, '同意！很推荐', 5, 0, FALSE, 1, '2024-12-26 10:15:00');

-- 插入评论点赞
INSERT INTO `comment_like` (`id`, `comment_id`, `user_id`, `status`, `created_at`) VALUES
(6001, 5001, 1001, 1, '2024-12-28 09:36:00'), (6002, 5001, 1002, 1, '2024-12-28 09:40:00'),
(6003, 5004, 1001, 1, '2024-12-28 11:06:00'), (6004, 5005, 1002, 1, '2024-12-26 10:05:00');

-- 插入草稿（包含location默认值）
INSERT INTO `content_draft` (`id`, `user_id`, `type`, `title`, `content`, `location`, `auto_save_time`, `expire_time`, `status`, `created_at`) VALUES
(3001, 1001, 1, '技术博客草稿', 'React Hooks深入理解', ST_GeomFromText('POINT(0 0)', 4326), '2024-12-29 15:30:00', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '2024-12-29 15:00:00'),
(3002, 1002, 2, '设计沙龙活动', 'UI设计交流活动', ST_GeomFromText('POINT(0 0)', 4326), '2024-12-29 16:20:00', DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '2024-12-29 16:00:00');

-- 插入话题
INSERT INTO `topic` (`id`, `name`, `description`, `cover_url`, `creator_id`, `category`, `is_hot`, `is_trending`, `status`, `created_at`) VALUES
(4001, '#React#', 'React前端技术', 'https://picsum.photos/300?random=401', 1001, 1, TRUE, TRUE, 2, '2024-12-01 10:00:00'),
(4002, '#UI设计#', 'UI/UX设计', 'https://picsum.photos/300?random=402', 1002, 2, TRUE, FALSE, 2, '2024-12-01 11:00:00'),
(4003, '#Java#', 'Java编程', 'https://picsum.photos/300?random=403', 1004, 1, TRUE, TRUE, 3, '2024-12-01 12:00:00'),
(4004, '#SpringBoot#', 'Spring Boot开发', 'https://picsum.photos/300?random=404', 1001, 1, TRUE, FALSE, 1, '2024-12-01 13:00:00');

-- 插入话题统计
INSERT INTO `topic_stats` (`topic_id`, `participant_count`, `post_count`, `view_count`, `like_count`, `follow_count`, `heat_score`, `trend_score`, `today_post_count`, `week_post_count`, `month_post_count`, `updated_at`) VALUES
(4001, 1250, 380, 15600, 2580, 820, 12500, 8.5, 15, 45, 125, NOW()),
(4002, 980, 295, 12300, 1950, 650, 9800, 6.2, 12, 38, 98, NOW()),
(4003, 1580, 520, 22800, 3850, 1100, 15800, 12.3, 25, 68, 185, NOW()),
(4004, 850, 210, 9500, 1420, 580, 8500, 5.8, 8, 28, 72, NOW());

-- 插入内容话题关联
INSERT INTO `content_topic` (`id`, `content_id`, `topic_id`, `sort_order`, `created_at`) VALUES
(7001, 2001, 4001, 1, '2024-12-28 09:00:00'), (7002, 2002, 4002, 1, '2024-12-28 10:30:00'),
(7003, 2003, 4003, 1, '2024-12-28 14:00:00'), (7004, 2003, 4004, 2, '2024-12-28 14:00:00'),
(7005, 2201, 4001, 1, '2024-12-25 10:00:00'), (7006, 2202, 4002, 1, '2024-12-25 14:00:00'),
(7007, 2203, 4003, 1, '2024-12-25 16:00:00');

-- 插入话题关注
INSERT INTO `topic_follow` (`id`, `user_id`, `topic_id`, `status`, `created_at`) VALUES
(8001, 1001, 4001, 1, '2024-12-02 10:00:00'), (8002, 1003, 4001, 1, '2024-12-03 11:00:00'),
(8003, 1002, 4002, 1, '2024-12-02 13:00:00'), (8004, 1001, 4003, 1, '2024-12-02 16:00:00'),
(8005, 1003, 4003, 1, '2024-12-02 17:00:00'), (8006, 1001, 4004, 1, '2024-12-05 10:00:00');

-- 插入行为数据
INSERT INTO `content_action` (`id`, `content_id`, `user_id`, `action`, `status`, `created_at`) VALUES
(9001, 2001, 1002, 1, 1, '2024-12-28 09:15:00'), (9002, 2001, 1003, 1, 1, '2024-12-28 09:30:00'),
(9003, 2002, 1001, 1, 1, '2024-12-28 10:45:00'), (9004, 2201, 1003, 3, 1, '2024-12-25 11:05:00'),
(9005, 2203, 1003, 3, 1, '2024-12-25 17:00:00');

SELECT '✅ 测试数据初始化完成！' AS message,
    (SELECT COUNT(*) FROM content) AS content_count,
    (SELECT COUNT(*) FROM content_stats) AS stats_count,
    (SELECT COUNT(*) FROM comment) AS comment_count,
    (SELECT COUNT(*) FROM topic) AS topic_count;

-- 验证location字段数据
SELECT '🗺️ 验证地理位置数据：' AS title;

SELECT 
    id AS '内容ID',
    title AS '标题',
    location_name AS '地点名称',
    ST_AsText(location) AS '坐标',
    CASE 
        WHEN ST_AsText(location) = 'POINT(0 0)' THEN '默认坐标'
        ELSE '真实坐标'
    END AS '坐标类型'
FROM content
ORDER BY id;

SELECT 
    CASE 
        WHEN ST_AsText(location) = 'POINT(0 0)' THEN '默认坐标'
        ELSE '真实坐标'
    END AS '坐标类型',
    COUNT(*) AS '数量'
FROM content
GROUP BY 坐标类型;


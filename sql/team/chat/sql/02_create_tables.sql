-- ==========================================
-- Eve - 聊天模块表结构（v7.1完整版）
-- ==========================================
-- 负责人: Eve (后端聊天服务工程师)
-- 模块: xypai-chat
-- 数据库: xypai_chat
-- 版本: v7.1
-- 表数量: 5张
-- 字段总数: 78个
-- 参考: PL.md v7.1 (聊天模块设计)
-- ==========================================

-- ==========================================
-- 步骤0：创建数据库（如果不存在）
-- ==========================================
-- 说明：XY相遇派-聊天模块数据库

CREATE DATABASE IF NOT EXISTS `xypai_chat` 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

SELECT '✅ 数据库xypai_chat创建成功' AS status;

USE `xypai_chat`;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- 表1: chat_conversation（聊天会话表 - 15字段）
-- ==========================================
-- 参考: PL.md 第1585-1628行
-- 功能: 私聊/群聊/系统通知/订单会话管理
-- ==========================================

CREATE TABLE IF NOT EXISTS `chat_conversation` (
    -- ===== 主键 =====
    `id` BIGINT NOT NULL COMMENT '会话唯一ID(雪花ID)',
    
    -- ===== 基础信息（4字段） =====
    `type` TINYINT NOT NULL COMMENT '会话类型(1=私聊,2=群聊,3=系统通知,4=订单会话)',
    `title` VARCHAR(100) DEFAULT NULL COMMENT '会话标题(群聊名称,私聊可为空)',
    `creator_id` BIGINT DEFAULT NULL COMMENT '创建者ID(群主/发起人)',
    `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '会话头像URL(群聊头像或对方头像)',
    
    -- ===== 扩展信息（2字段） =====
    `description` TEXT COMMENT '会话描述(群聊公告等)',
    `order_id` BIGINT COMMENT '关联订单ID(订单会话使用)',
    
    -- ===== 冗余字段（4字段）⭐ 性能优化 =====
    `last_message_id` BIGINT COMMENT '最后一条消息ID(冗余优化,提升列表查询)',
    `last_message_time` DATETIME COMMENT '最后消息时间(用于对话列表排序)',
    `total_message_count` INT DEFAULT 0 COMMENT '消息总数(冗余统计)',
    `member_count` INT DEFAULT 0 COMMENT '成员数量(群聊使用)',
    
    -- ===== 状态字段（2字段） =====
    `status` TINYINT DEFAULT 1 COMMENT '会话状态(0=已解散,1=正常,2=已归档)',
    `deleted_at` DATETIME COMMENT '软删除时间',
    
    -- ===== 系统字段（3字段） =====
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活跃时间',
    
    PRIMARY KEY (`id`),
    KEY `idx_type` (`type`),
    KEY `idx_creator_id` (`creator_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='聊天会话表(v7.1完整版)';

SELECT '✅ chat_conversation表创建成功（15字段）' AS status;

-- ==========================================
-- 表2: chat_message（聊天消息表 - 23字段）⚠️核心表
-- ==========================================
-- 参考: PL.md 第1630-1695行
-- 功能: 多媒体消息/已读回执/点赞/撤回/消息去重/消息有序
-- ==========================================

CREATE TABLE IF NOT EXISTS `chat_message` (
    -- ===== 主键 =====
    `id` BIGINT NOT NULL COMMENT '消息唯一ID(雪花ID)',
    
    -- ===== 基础信息（4字段） =====
    `conversation_id` BIGINT NOT NULL COMMENT '所属会话ID',
    `sender_id` BIGINT DEFAULT NULL COMMENT '发送者ID(NULL=系统消息)',
    `message_type` TINYINT NOT NULL COMMENT '消息类型(1=文本,2=图片,3=语音,4=视频,5=文件,6=系统通知,7=表情,8=位置)',
    `content` TEXT NOT NULL COMMENT '消息内容(文字内容或媒体描述,最大5000字符)',
    
    -- ===== 媒体字段（7字段）⭐ v7.1展开 =====
    `media_url` VARCHAR(500) COMMENT '媒体文件URL(CDN地址)',
    `thumbnail_url` VARCHAR(500) COMMENT '缩略图URL(图片缩略图或视频封面)',
    `media_size` BIGINT COMMENT '媒体文件大小(字节)',
    `media_width` INT COMMENT '媒体宽度(像素,图片/视频)',
    `media_height` INT COMMENT '媒体高度(像素,图片/视频)',
    `media_duration` INT COMMENT '媒体时长(秒,音频/视频,语音最长60s)',
    `media_caption` VARCHAR(500) COMMENT '媒体配文(图片/视频的文字说明)',
    
    -- ===== 消息管理字段（6字段）⭐ v7.1核心功能 =====
    `reply_to_id` BIGINT DEFAULT NULL COMMENT '回复的消息ID(引用回复功能)',
    `client_id` VARCHAR(100) UNIQUE COMMENT '客户端消息ID(用于消息去重)⭐',
    `sequence_id` BIGINT COMMENT '消息序列号(保证消息有序性)⭐',
    `delivery_status` TINYINT DEFAULT 0 COMMENT '投递状态(0=发送中,1=已发送,2=已送达,3=已读,4=发送失败)',
    `read_count` INT DEFAULT 0 COMMENT '已读人数(群聊使用)',
    `like_count` INT DEFAULT 0 COMMENT '点赞数量(图片消息支持点赞)',
    
    -- ===== 撤回功能（1字段）⭐ v7.1新增 =====
    `recalled_by` BIGINT COMMENT '撤回操作人ID(群聊场景需要知道谁撤回)',
    
    -- ===== 时间字段（2字段）⭐ v7.1分离 =====
    `send_time` DATETIME COMMENT '客户端发送时间',
    `server_time` DATETIME COMMENT '服务器接收时间',
    
    -- ===== 状态字段（2字段） =====
    `status` TINYINT DEFAULT 1 COMMENT '消息状态(0=已删除,1=正常,2=已撤回)',
    `deleted_at` DATETIME COMMENT '软删除时间',
    
    -- ===== 系统字段（1字段） =====
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    PRIMARY KEY (`id`),
    KEY `idx_conversation_id` (`conversation_id`),
    KEY `idx_sender_id` (`sender_id`),
    KEY `idx_message_type` (`message_type`),
    KEY `idx_reply_to_id` (`reply_to_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`),
    CONSTRAINT `fk_chat_message_conversation` 
      FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversation` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_chat_message_reply` 
      FOREIGN KEY (`reply_to_id`) REFERENCES `chat_message` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='聊天消息表(v7.1完整版)';

SELECT '✅ chat_message表创建成功（23字段）' AS status;

-- ==========================================
-- 表3: chat_participant（会话参与者表 - 13字段）
-- ==========================================
-- 参考: PL.md 第1697-1728行
-- 功能: 个性化设置/已读管理/角色权限
-- ==========================================

CREATE TABLE IF NOT EXISTS `chat_participant` (
    -- ===== 主键 =====
    `id` BIGINT NOT NULL COMMENT '参与记录ID',
    
    -- ===== 关联信息（3字段） =====
    `conversation_id` BIGINT NOT NULL COMMENT '会话ID',
    `user_id` BIGINT NOT NULL COMMENT '参与用户ID',
    `role` TINYINT DEFAULT 1 COMMENT '角色权限(1=成员,2=管理员,3=群主)',
    
    -- ===== 加入信息（1字段） =====
    `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    
    -- ===== 已读管理（3字段）⭐ v7.1精确定位 =====
    `last_read_time` DATETIME DEFAULT NULL COMMENT '最后已读时间(计算未读数)',
    `last_read_message_id` BIGINT COMMENT '最后已读消息ID(精确定位已读位置)⭐',
    `unread_count` INT DEFAULT 0 COMMENT '未读消息数(冗余字段,实时更新)⭐',
    
    -- ===== 个性化设置（4字段）⭐ v7.1新增 =====
    `is_pinned` BOOLEAN DEFAULT FALSE COMMENT '是否置顶此会话(用户个性化)',
    `is_muted` BOOLEAN DEFAULT FALSE COMMENT '是否免打扰(不接收推送)',
    `mute_until` DATETIME COMMENT '免打扰截止时间(NULL=永久免打扰)',
    `nickname` VARCHAR(100) COMMENT '群聊中的昵称(群昵称,可选)',
    
    -- ===== 状态字段（2字段） =====
    `status` TINYINT DEFAULT 1 COMMENT '参与状态(0=已退出,1=正常,2=已禁言)',
    `leave_time` DATETIME COMMENT '退出时间',
    
    PRIMARY KEY (`id`),
    KEY `idx_conversation_id` (`conversation_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_role` (`role`),
    KEY `idx_status` (`status`),
    KEY `idx_last_read_time` (`last_read_time`),
    UNIQUE KEY `uk_conversation_user` (`conversation_id`, `user_id`),
    CONSTRAINT `fk_chat_participant_conversation` 
      FOREIGN KEY (`conversation_id`) REFERENCES `chat_conversation` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='会话参与者表(v7.1完整版)';

SELECT '✅ chat_participant表创建成功（13字段）' AS status;

-- ==========================================
-- 表4: message_settings（用户消息设置表 - 20字段）🆕
-- ==========================================
-- 参考: PL.md 第1730-1777行
-- 功能: 消息推送设置/隐私设置/自动下载设置
-- ==========================================

CREATE TABLE IF NOT EXISTS `message_settings` (
    -- ===== 主键 =====
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设置记录ID',
    `user_id` BIGINT NOT NULL UNIQUE COMMENT '用户ID(唯一)',
    
    -- ===== 推送设置（6字段） =====
    `push_enabled` BOOLEAN DEFAULT TRUE COMMENT '推送总开关',
    `push_sound_enabled` BOOLEAN DEFAULT TRUE COMMENT '推送声音开关',
    `push_vibrate_enabled` BOOLEAN DEFAULT TRUE COMMENT '推送震动开关',
    `push_preview_enabled` BOOLEAN DEFAULT TRUE COMMENT '推送内容预览开关',
    `push_start_time` VARCHAR(10) DEFAULT '08:00' COMMENT '推送时段开始时间',
    `push_end_time` VARCHAR(10) DEFAULT '22:00' COMMENT '推送时段结束时间',
    
    -- ===== 分类推送（4字段） =====
    `push_like_enabled` BOOLEAN DEFAULT TRUE COMMENT '点赞消息推送开关',
    `push_comment_enabled` BOOLEAN DEFAULT TRUE COMMENT '评论消息推送开关',
    `push_follow_enabled` BOOLEAN DEFAULT TRUE COMMENT '关注消息推送开关',
    `push_system_enabled` BOOLEAN DEFAULT TRUE COMMENT '系统通知推送开关',
    
    -- ===== 隐私设置（2字段） =====
    `who_can_message` TINYINT DEFAULT 0 COMMENT '谁可以给我发消息(0=所有人,1=我关注的人,2=互相关注,3=不允许)',
    `who_can_add_friend` TINYINT DEFAULT 0 COMMENT '谁可以添加我为好友(0=所有人,1=需要验证,2=不允许)',
    
    -- ===== 消息设置（2字段） =====
    `message_read_receipt` BOOLEAN DEFAULT TRUE COMMENT '消息已读回执开关',
    `online_status_visible` BOOLEAN DEFAULT TRUE COMMENT '在线状态可见',
    
    -- ===== 自动下载（3字段） =====
    `auto_download_image` TINYINT DEFAULT 2 COMMENT '自动下载图片(0=永不,1=仅WIFI,2=始终)',
    `auto_download_video` TINYINT DEFAULT 1 COMMENT '自动下载视频(0=永不,1=仅WIFI,2=始终)',
    `auto_play_voice` BOOLEAN DEFAULT FALSE COMMENT '自动播放语音消息',
    
    -- ===== 其他（1字段） =====
    `message_retention_days` INT DEFAULT 0 COMMENT '消息保存天数(0=永久,7/30/90天自动清理)',
    
    -- ===== 系统字段（2字段） =====
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户消息设置表(v7.1新增)';

SELECT '✅ message_settings表创建成功（20字段）' AS status;

-- ==========================================
-- 表5: typing_status（正在输入状态表 - 7字段）🆕
-- ==========================================
-- 参考: PL.md 第1779-1796行
-- 功能: 正在输入状态管理
-- 建议: 实际使用Redis替代，性能更好
-- ==========================================

CREATE TABLE IF NOT EXISTS `typing_status` (
    -- ===== 主键 =====
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '状态记录ID',
    
    -- ===== 关联信息（2字段） =====
    `conversation_id` BIGINT NOT NULL COMMENT '对话ID',
    `user_id` BIGINT NOT NULL COMMENT '正在输入的用户ID',
    
    -- ===== 状态信息（1字段） =====
    `is_typing` BOOLEAN DEFAULT TRUE COMMENT '是否正在输入(0=停止,1=输入中)',
    
    -- ===== 时间信息（3字段） =====
    `start_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '开始输入时间',
    `last_update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间(心跳更新)',
    `expire_time` DATETIME COMMENT '过期时间(10秒无更新自动清除)',
    
    UNIQUE KEY `uk_conversation_user` (`conversation_id`, `user_id`),
    KEY `idx_expire` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='正在输入状态表(v7.1新增，建议用Redis替代)';

SELECT '✅ typing_status表创建成功（7字段）' AS status;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 表结构创建完成验证
-- ==========================================

SELECT 
  '✅ Eve聊天模块表结构创建完成！' AS result,
  '5张表' AS total_tables,
  '78个字段' AS total_fields;

-- 显示所有表
SELECT 
  TABLE_NAME AS '表名',
  TABLE_COMMENT AS '表说明',
  (SELECT COUNT(*) FROM information_schema.COLUMNS 
   WHERE TABLE_SCHEMA = 'xypai_chat' AND TABLE_NAME = t.TABLE_NAME) AS '字段数'
FROM information_schema.TABLES t
WHERE TABLE_SCHEMA = 'xypai_chat'
ORDER BY TABLE_NAME;

-- ==========================================
-- 下一步: 执行 03_create_indexes.sql 创建索引
-- ==========================================


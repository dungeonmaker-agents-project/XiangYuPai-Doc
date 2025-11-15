-- ==========================================
-- Bob用户模块 - 创建表结构（优化版）
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 版本: v8.0 (优化版)
-- 表数量: 7张（合并user+user_profile，删除冗余认证字段）
-- 字段数量: 106个
-- ==========================================

-- ==========================================
-- 清理旧数据库并重新创建
-- ==========================================

-- 删除旧数据库（如果存在）
DROP DATABASE IF EXISTS `xypai_user`;

-- 创建新数据库
CREATE DATABASE `xypai_user` 
  DEFAULT CHARACTER SET utf8mb4 
  DEFAULT COLLATE utf8mb4_unicode_ci
  COMMENT 'XiangYuPai用户业务数据库';

-- 使用数据库
USE `xypai_user`;

SELECT '✅ 数据库 xypai_user 已重新创建' AS message;

-- ==========================================
-- 表1: user（用户业务信息表 - 41字段）
-- ==========================================
-- 说明：只存储APP业务属性，不包含认证信息（认证在sys_user中）

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` BIGINT NOT NULL COMMENT '关联sys_user的用户ID',
  
  -- ===== 基础资料（9字段）=====
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '用户昵称',
  `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `avatar_thumbnail` VARCHAR(500) DEFAULT NULL COMMENT '头像缩略图',
  `background_image` VARCHAR(500) DEFAULT NULL COMMENT '背景图',
  `gender` TINYINT DEFAULT 0 COMMENT '性别(0=未设置,1=男,2=女,3=其他)',
  `birthday` DATE DEFAULT NULL COMMENT '生日',
  `age` INT DEFAULT NULL COMMENT '年龄',
  `bio` VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
  
  -- ===== 位置信息（4字段）=====
  `city_id` BIGINT DEFAULT NULL COMMENT '城市ID',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '位置信息',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '详细地址',
  `ip_location` VARCHAR(100) DEFAULT NULL COMMENT 'IP归属地',
  
  -- ===== 体征信息（2字段）=====
  `height` INT DEFAULT NULL COMMENT '身高(cm)',
  `weight` INT DEFAULT NULL COMMENT '体重(kg)',
  
  -- ===== 实名信息（3字段）=====
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `id_card_encrypted` VARCHAR(200) DEFAULT NULL COMMENT '身份证号(加密)',
  `is_real_verified` BOOLEAN DEFAULT FALSE COMMENT '是否实名认证',
  
  -- ===== 社交联系（3字段）=====
  `wechat` VARCHAR(50) DEFAULT NULL COMMENT '微信号',
  `wechat_unlock_condition` TINYINT DEFAULT 0 COMMENT '微信解锁条件(0=公开,1=关注后可见,2=付费可见)',
  
  -- ===== 用户认证标识（5字段）=====
  `is_god_verified` BOOLEAN DEFAULT FALSE COMMENT '大神认证',
  `is_activity_expert` BOOLEAN DEFAULT FALSE COMMENT '组局达人',
  `is_vip` BOOLEAN DEFAULT FALSE COMMENT 'VIP用户',
  `is_popular` BOOLEAN DEFAULT FALSE COMMENT '人气用户',
  `vip_level` TINYINT DEFAULT 0 COMMENT 'VIP等级(0-9)',
  `vip_expire_time` DATETIME DEFAULT NULL COMMENT 'VIP过期时间',
  
  -- ===== 在线状态（2字段）=====
  `online_status` TINYINT DEFAULT 0 COMMENT '在线状态(0=离线,1=在线,2=忙碌)',
  `last_online_time` DATETIME DEFAULT NULL COMMENT '最后在线时间',
  
  -- ===== 资料完整度（2字段）=====
  `profile_completeness` INT DEFAULT 0 COMMENT '资料完整度(0-100)',
  `last_edit_time` DATETIME DEFAULT NULL COMMENT '最后编辑时间',
  
  -- ===== 审计字段（4字段）=====
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间',
  `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
  
  PRIMARY KEY (`user_id`),
  KEY `idx_city_gender` (`city_id`, `gender`, `is_real_verified`) COMMENT '附近的人查询',
  KEY `idx_online_status` (`online_status`, `last_online_time`) COMMENT '在线用户查询',
  KEY `idx_vip` (`is_vip`, `vip_level`) COMMENT 'VIP用户查询',
  KEY `idx_popular` (`is_popular`, `is_real_verified`) COMMENT '人气用户查询',
  KEY `idx_completeness` (`profile_completeness`) COMMENT '资料完整度排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='APP用户业务信息表（不含认证信息）';

-- ==========================================
-- 表2: user_stats（用户统计表 - 13字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_stats` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `follower_count` INT DEFAULT 0 COMMENT '粉丝数',
  `following_count` INT DEFAULT 0 COMMENT '关注数',
  `content_count` INT DEFAULT 0 COMMENT '内容数',
  `total_like_count` INT DEFAULT 0 COMMENT '获赞数',
  `total_collect_count` INT DEFAULT 0 COMMENT '收藏数',
  `activity_organizer_count` INT DEFAULT 0 COMMENT '发起组局数',
  `activity_participant_count` INT DEFAULT 0 COMMENT '参与组局数',
  `activity_success_count` INT DEFAULT 0 COMMENT '成功组局数',
  `activity_cancel_count` INT DEFAULT 0 COMMENT '取消组局数',
  `activity_organizer_score` DECIMAL(3,2) DEFAULT 0.00 COMMENT '组局评分(0-5)',
  `activity_success_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '组局成功率(%)',
  `last_sync_time` DATETIME DEFAULT NULL COMMENT '最后同步时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `idx_follower` (`follower_count` DESC) COMMENT '粉丝排行',
  KEY `idx_organizer_score` (`activity_organizer_score` DESC) COMMENT '组局评分排行'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户统计表(Redis缓存)';

-- ==========================================
-- 表3: occupation_dict（职业字典表 - 7字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `occupation_dict` (
  `code` VARCHAR(50) NOT NULL COMMENT '职业编码',
  `name` VARCHAR(50) NOT NULL COMMENT '职业名称',
  `category` VARCHAR(50) DEFAULT NULL COMMENT '职业分类',
  `icon_url` VARCHAR(500) DEFAULT NULL COMMENT '图标URL',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态(0=禁用,1=启用)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`code`),
  KEY `idx_category` (`category`, `sort_order`) COMMENT '分类排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职业字典表';

-- ==========================================
-- 表4: user_occupation（用户职业关联表 - 5字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_occupation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `occupation_code` VARCHAR(50) NOT NULL COMMENT '职业编码',
  `sort_order` INT DEFAULT 0 COMMENT '排序(0=主职业)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_occupation` (`user_id`, `occupation_code`),
  KEY `idx_user` (`user_id`, `sort_order`) COMMENT '用户职业查询',
  KEY `idx_occupation` (`occupation_code`) COMMENT '职业用户查询',
  CONSTRAINT `fk_occupation_code` FOREIGN KEY (`occupation_code`) 
    REFERENCES `occupation_dict` (`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户职业关联表（支持多职业）';

-- ==========================================
-- 表5: user_wallet（用户钱包表 - 8字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_wallet` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `balance` BIGINT DEFAULT 0 COMMENT '可用余额(分)',
  `frozen` BIGINT DEFAULT 0 COMMENT '冻结金额(分)',
  `coin_balance` BIGINT DEFAULT 0 COMMENT '金币余额',
  `total_income` BIGINT DEFAULT 0 COMMENT '累计收入(分)',
  `total_expense` BIGINT DEFAULT 0 COMMENT '累计支出(分)',
  `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `idx_balance` (`balance`) COMMENT '余额查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户钱包表';

-- ==========================================
-- 表6: transaction（交易流水表 - 13字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `transaction` (
  `id` BIGINT NOT NULL COMMENT '交易ID(雪花ID)',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `amount` BIGINT NOT NULL COMMENT '交易金额(分)',
  `type` VARCHAR(20) NOT NULL COMMENT '交易类型(recharge/consume/refund/withdraw)',
  `ref_type` VARCHAR(20) DEFAULT NULL COMMENT '关联类型(order/activity/system)',
  `ref_id` BIGINT DEFAULT NULL COMMENT '关联业务ID',
  `status` TINYINT DEFAULT 0 COMMENT '交易状态(0=处理中,1=成功,2=失败)',
  `payment_method` VARCHAR(20) DEFAULT NULL COMMENT '支付方式(wechat/alipay/balance)',
  `payment_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方支付流水号',
  `balance_before` BIGINT DEFAULT NULL COMMENT '交易前余额(分)',
  `balance_after` BIGINT DEFAULT NULL COMMENT '交易后余额(分)',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '交易描述',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '交易时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`, `type`, `created_at`) COMMENT '用户交易查询',
  KEY `idx_ref` (`ref_type`, `ref_id`) COMMENT '关联业务查询',
  KEY `idx_status` (`status`, `created_at`) COMMENT '状态查询',
  KEY `idx_payment_no` (`payment_no`) COMMENT '支付流水号查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易流水表';

-- ==========================================
-- 表7: user_relation（用户关系表 - 7字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_relation` (
  `id` BIGINT NOT NULL COMMENT '关系ID(雪花ID)',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `target_id` BIGINT NOT NULL COMMENT '目标用户ID',
  `type` INT NOT NULL COMMENT '关系类型(1=关注,2=拉黑,3=好友,4=特别关注)',
  `status` TINYINT DEFAULT 1 COMMENT '状态(0=已取消,1=正常)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target_type` (`user_id`, `target_id`, `type`) COMMENT '唯一关系约束',
  KEY `idx_user_type` (`user_id`, `type`, `status`) COMMENT '用户关系查询',
  KEY `idx_target_type` (`target_id`, `type`, `status`) COMMENT '被关注查询',
  KEY `idx_created` (`created_at`) COMMENT '时间排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户关系表';

SELECT '✅ Bob用户模块：7张表创建成功（优化版）' AS message,
       '优化：合并user+user_profile，删除认证冗余字段' AS optimization;


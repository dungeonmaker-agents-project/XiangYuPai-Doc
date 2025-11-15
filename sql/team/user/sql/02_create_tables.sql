-- ==========================================
-- Bob用户模块 - 创建表结构
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 版本: v7.1
-- 表数量: 8张
-- 字段数量: 113个
-- 参考: PL.md v7.1完整设计
-- ==========================================

USE `xypai_user`;

-- ==========================================
-- 表1: user（用户基础表 - 19字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL COMMENT '用户唯一标识(雪花ID)',
  `username` VARCHAR(50) NOT NULL COMMENT '登录用户名(唯一)',
  `mobile` VARCHAR(20) NOT NULL COMMENT '手机号(唯一,主要登录凭证)',
  `region_code` VARCHAR(10) DEFAULT '+86' COMMENT '地区代码(如+86)',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱(唯一,辅助登录凭证)',
  `password` VARCHAR(100) NOT NULL COMMENT '密码哈希值(BCrypt加密)',
  `password_salt` VARCHAR(100) DEFAULT NULL COMMENT '密码盐值',
  `password_updated_at` DATETIME DEFAULT NULL COMMENT '密码最后更新时间',
  `status` TINYINT DEFAULT 1 COMMENT '用户状态(0=禁用,1=正常,2=冻结,3=待激活)',
  `login_fail_count` INT DEFAULT 0 COMMENT '登录失败次数(防暴力破解)',
  `login_locked_until` DATETIME DEFAULT NULL COMMENT '账户锁定截止时间',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
  `last_login_device_id` VARCHAR(100) DEFAULT NULL COMMENT '最后登录设备ID',
  `is_two_factor_enabled` BOOLEAN DEFAULT FALSE COMMENT '是否启用双因子认证',
  `two_factor_secret` VARCHAR(100) DEFAULT NULL COMMENT '双因子认证密钥(TOTP)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除(0=正常,1=已删除)',
  `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_mobile` (`mobile`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户基础信息表';

-- ==========================================
-- 表2: user_profile（用户资料表 - 42字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_profile` (
  `user_id` BIGINT NOT NULL COMMENT '关联用户ID',
  `nickname` VARCHAR(50) DEFAULT NULL COMMENT '用户昵称',
  `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
  `avatar_thumbnail` VARCHAR(500) DEFAULT NULL COMMENT '头像缩略图',
  `background_image` VARCHAR(500) DEFAULT NULL COMMENT '背景图',
  `gender` TINYINT DEFAULT 0 COMMENT '性别(0=未设置,1=男,2=女,3=其他)',
  `birthday` DATE DEFAULT NULL COMMENT '生日',
  `age` INT DEFAULT NULL COMMENT '年龄',
  `city_id` BIGINT DEFAULT NULL COMMENT '城市ID',
  `location` VARCHAR(100) DEFAULT NULL COMMENT '位置信息',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '详细地址',
  `ip_location` VARCHAR(100) DEFAULT NULL COMMENT 'IP归属地',
  `bio` VARCHAR(500) DEFAULT NULL COMMENT '个人简介',
  `height` INT DEFAULT NULL COMMENT '身高(cm)',
  `weight` INT DEFAULT NULL COMMENT '体重(kg)',
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `id_card_encrypted` VARCHAR(200) DEFAULT NULL COMMENT '身份证号(加密)',
  `wechat` VARCHAR(50) DEFAULT NULL COMMENT '微信号',
  `wechat_unlock_condition` TINYINT DEFAULT 0 COMMENT '微信解锁条件',
  `is_real_verified` BOOLEAN DEFAULT FALSE COMMENT '实名认证',
  `is_god_verified` BOOLEAN DEFAULT FALSE COMMENT '大神认证',
  `is_activity_expert` BOOLEAN DEFAULT FALSE COMMENT '组局达人',
  `is_vip` BOOLEAN DEFAULT FALSE COMMENT 'VIP用户',
  `is_popular` BOOLEAN DEFAULT FALSE COMMENT '人气用户',
  `vip_level` TINYINT DEFAULT 0 COMMENT 'VIP等级',
  `vip_expire_time` DATETIME DEFAULT NULL COMMENT 'VIP过期时间',
  `online_status` TINYINT DEFAULT 0 COMMENT '在线状态',
  `last_online_time` DATETIME DEFAULT NULL COMMENT '最后在线时间',
  `profile_completeness` INT DEFAULT 0 COMMENT '资料完整度(0-100)',
  `last_edit_time` DATETIME DEFAULT NULL COMMENT '最后编辑时间',
  `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `version` INT DEFAULT 0 COMMENT '乐观锁',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_profile_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户资料表';

-- ==========================================
-- 表3: user_stats（用户统计表 - 13字段）⭐
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
  `activity_organizer_score` DECIMAL(3,2) DEFAULT 0.00 COMMENT '组局评分',
  `activity_success_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '组局成功率',
  `last_sync_time` DATETIME DEFAULT NULL COMMENT '最后同步时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_stats_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户统计表(Redis缓存)';

-- ==========================================
-- 表4: occupation_dict（职业字典表 - 7字段）⭐
-- ==========================================

CREATE TABLE IF NOT EXISTS `occupation_dict` (
  `code` VARCHAR(50) NOT NULL COMMENT '职业编码',
  `name` VARCHAR(50) NOT NULL COMMENT '职业名称',
  `category` VARCHAR(50) DEFAULT NULL COMMENT '职业分类',
  `icon_url` VARCHAR(500) DEFAULT NULL COMMENT '图标URL',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `status` TINYINT DEFAULT 1 COMMENT '状态',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职业字典表';

-- ==========================================
-- 表5: user_occupation（用户职业关联表 - 4字段）⭐
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_occupation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `occupation_code` VARCHAR(50) NOT NULL COMMENT '职业编码',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_occupation` (`user_id`, `occupation_code`),
  CONSTRAINT `fk_occupation_code` FOREIGN KEY (`occupation_code`) REFERENCES `occupation_dict` (`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户职业关联表';

-- ==========================================
-- 表6: user_wallet（用户钱包表 - 8字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_wallet` (
  `user_id` BIGINT NOT NULL,
  `balance` BIGINT DEFAULT 0 COMMENT '可用余额(分)',
  `frozen` BIGINT DEFAULT 0 COMMENT '冻结金额(分)',
  `coin_balance` BIGINT DEFAULT 0 COMMENT '金币余额',
  `total_income` BIGINT DEFAULT 0 COMMENT '累计收入(分)',
  `total_expense` BIGINT DEFAULT 0 COMMENT '累计支出(分)',
  `version` INT DEFAULT 0 COMMENT '乐观锁',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户钱包表';

-- ==========================================
-- 表7: transaction（交易流水表 - 13字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `transaction` (
  `id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `amount` BIGINT NOT NULL COMMENT '交易金额(分)',
  `type` VARCHAR(20) NOT NULL COMMENT '交易类型',
  `ref_type` VARCHAR(20) DEFAULT NULL COMMENT '关联类型',
  `ref_id` BIGINT DEFAULT NULL COMMENT '关联ID',
  `status` TINYINT DEFAULT 0 COMMENT '交易状态',
  `payment_method` VARCHAR(20) DEFAULT NULL COMMENT '支付方式',
  `payment_no` VARCHAR(100) DEFAULT NULL COMMENT '支付流水号',
  `description` VARCHAR(255) DEFAULT NULL COMMENT '交易描述',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_type` (`user_id`, `type`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='交易流水表';

-- ==========================================
-- 表8: user_relation（用户关系表 - 7字段）
-- ==========================================

CREATE TABLE IF NOT EXISTS `user_relation` (
  `id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `target_id` BIGINT NOT NULL,
  `type` INT NOT NULL COMMENT '关系类型(1=关注,2=拉黑,3=好友,4=特别关注)',
  `status` TINYINT DEFAULT 1 COMMENT '状态',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target_type` (`user_id`, `target_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户关系表';

SELECT '✅ Bob用户模块：8张表创建成功' AS message;


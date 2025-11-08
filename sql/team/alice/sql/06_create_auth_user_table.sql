-- ==========================================
-- Alice - 认证域用户表
-- ==========================================
-- 目标: 将认证数据从 xypai_user 迁移到 xypai_auth
-- 原则: 认证域与业务域完全分离
-- 参考: ARCHITECTURE_UPGRADE_MASTER_PLAN.md
-- ==========================================

USE `xypai_auth`;

-- ==========================================
-- 表: user (用户认证表) 🆕
-- ==========================================
-- 职责: 仅存储认证相关字段（19字段）
-- 原数据源: xypai_user.user（认证字段部分）
-- ==========================================

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` BIGINT NOT NULL COMMENT '用户ID（全局唯一，雪花ID）',
  
  -- 🔐 认证凭证（核心字段）
  `username` VARCHAR(50) NOT NULL COMMENT '用户名（唯一）',
  `mobile` VARCHAR(20) NOT NULL COMMENT '手机号（唯一，主要登录凭证）',
  `region_code` VARCHAR(10) DEFAULT '+86' COMMENT '地区代码（如+86）',
  `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱（唯一，辅助登录凭证）',
  `password` VARCHAR(100) NOT NULL COMMENT '密码哈希值（BCrypt加密）',
  `password_salt` VARCHAR(100) DEFAULT NULL COMMENT '密码盐值（BCrypt自带盐，可选）',
  `password_updated_at` DATETIME DEFAULT NULL COMMENT '密码最后更新时间',
  
  -- 🚦 账号状态
  `status` TINYINT DEFAULT 1 COMMENT '用户状态（0=禁用,1=正常,2=冻结,3=待激活）',
  `login_fail_count` INT DEFAULT 0 COMMENT '登录失败次数（防暴力破解）',
  `login_locked_until` DATETIME DEFAULT NULL COMMENT '账户锁定截止时间',
  
  -- 📊 登录记录（快照，详细记录在 login_session）
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
  `last_login_device_id` VARCHAR(100) DEFAULT NULL COMMENT '最后登录设备ID',
  
  -- 🔒 安全设置
  `is_two_factor_enabled` BOOLEAN DEFAULT FALSE COMMENT '是否启用双因子认证',
  `two_factor_secret` VARCHAR(100) DEFAULT NULL COMMENT '双因子认证密钥（TOTP）',
  
  -- 📅 元数据
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除（0=正常,1=已删除）',
  `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_mobile` (`mobile`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户认证表 - 仅存储认证相关数据';

SELECT '✅ xypai_auth.user 表创建成功' AS status;
SELECT '📊 字段数量: 19' AS info;
SELECT '🎯 职责: 认证域数据' AS info2;


-- ==========================================
-- Alice - 认证模块表结构
-- ==========================================
-- 数据库: xypai_auth
-- 表数量: 5张
-- 字段总数: 71个
-- 设计参考: PL.md v7.1 (第289-651行)
-- ==========================================

-- 创建数据库架构
CREATE DATABASE IF NOT EXISTS `xypai_auth` 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

USE `xypai_auth`;

-- ==========================================
-- 表1: login_session (登录会话表) - 22字段
-- ==========================================
-- 设计参考: PL.md 第291-340行
-- 功能: 多设备并发登录、会话管理、远程注销、心跳保活
-- ==========================================

DROP TABLE IF EXISTS `login_session`;

CREATE TABLE `login_session` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '会话唯一ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `device_id` VARCHAR(100) NOT NULL COMMENT '设备唯一标识(设备指纹)',
  `access_token` VARCHAR(500) NOT NULL COMMENT '访问令牌(JWT格式,24小时有效期)',
  `refresh_token` VARCHAR(500) NOT NULL COMMENT '刷新令牌(7天有效期)',
  `token_type` VARCHAR(20) DEFAULT 'Bearer' COMMENT '令牌类型',
  `expires_at` DATETIME NOT NULL COMMENT '访问令牌过期时间',
  `refresh_expires_at` DATETIME NOT NULL COMMENT '刷新令牌过期时间',
  `login_type` TINYINT NOT NULL COMMENT '登录方式(1=密码登录,2=验证码登录,3=第三方登录)',
  `login_ip` VARCHAR(50) COMMENT '登录IP地址',
  `login_location` VARCHAR(100) COMMENT '登录地理位置(IP解析)',
  `user_agent` TEXT COMMENT '用户代理字符串',
  `device_type` VARCHAR(50) COMMENT '设备类型(iOS/Android/Web)',
  `device_name` VARCHAR(100) COMMENT '设备名称(如iPhone 13 Pro)',
  `os_type` VARCHAR(50) COMMENT '操作系统类型(iOS/Android/Windows等)',
  `os_version` VARCHAR(50) COMMENT '操作系统版本',
  `app_version` VARCHAR(50) COMMENT '应用版本号',
  `network_type` VARCHAR(20) COMMENT '网络类型(WiFi/4G/5G)',
  `is_trusted_device` BOOLEAN DEFAULT FALSE COMMENT '是否可信设备',
  `last_active_time` DATETIME COMMENT '最后活跃时间(用于心跳更新)',
  `status` TINYINT DEFAULT 1 COMMENT '会话状态(0=已过期,1=正常,2=已注销,3=异常)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='登录会话表-支持多设备并发登录';

-- ==========================================
-- 表2: sms_verification (短信验证码表) - 15字段
-- ==========================================
-- 设计参考: PL.md 第342-381行
-- 功能: 短信验证码持久化、防刷检测、验证次数限制、审计追溯
-- ==========================================

DROP TABLE IF EXISTS `sms_verification`;

CREATE TABLE `sms_verification` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '验证码记录ID',
  `mobile` VARCHAR(20) NOT NULL COMMENT '目标手机号',
  `region_code` VARCHAR(10) DEFAULT '+86' COMMENT '地区代码(如+86)',
  `sms_code` VARCHAR(10) NOT NULL COMMENT '验证码内容(6位数字)',
  `sms_token` VARCHAR(64) NOT NULL COMMENT '短信令牌(用于验证时绑定)',
  `verification_type` TINYINT NOT NULL COMMENT '验证类型(1=登录,2=注册,3=重置密码,4=修改手机号)',
  `scene` VARCHAR(50) NOT NULL COMMENT '业务场景标识(user_login/password_reset等)',
  `template_code` VARCHAR(50) COMMENT '短信模板代码',
  `send_status` TINYINT DEFAULT 0 COMMENT '发送状态(0=待发送,1=发送成功,2=发送失败)',
  `verify_status` TINYINT DEFAULT 0 COMMENT '验证状态(0=未验证,1=验证成功,2=验证失败,3=已过期)',
  `verify_count` INT DEFAULT 0 COMMENT '验证尝试次数',
  `max_verify_count` INT DEFAULT 3 COMMENT '最大尝试次数(默认3次)',
  `ip_address` VARCHAR(50) COMMENT '请求IP地址',
  `device_id` VARCHAR(100) COMMENT '设备标识',
  `send_time` DATETIME COMMENT '发送时间',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间(5分钟有效期)',
  `verify_time` DATETIME COMMENT '验证时间',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='短信验证码表-支持登录注册重置密码';

-- ==========================================
-- 表3: user_device (用户设备表) - 18字段
-- ==========================================
-- 设计参考: PL.md 第426-475行
-- 功能: 设备管理、信任设备、设备异常检测、远程注销
-- ==========================================

DROP TABLE IF EXISTS `user_device`;

CREATE TABLE `user_device` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '设备记录ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `device_id` VARCHAR(100) NOT NULL COMMENT '设备唯一标识',
  `device_fingerprint` VARCHAR(255) COMMENT '设备指纹(多维度组合生成)',
  `device_name` VARCHAR(100) COMMENT '设备名称(如iPhone 13 Pro)',
  `device_type` VARCHAR(50) COMMENT '设备类型(iOS/Android/Web/Tablet)',
  `device_brand` VARCHAR(50) COMMENT '设备品牌(Apple/Samsung/Huawei等)',
  `device_model` VARCHAR(100) COMMENT '设备型号',
  `os_type` VARCHAR(50) COMMENT '操作系统类型',
  `os_version` VARCHAR(50) COMMENT '操作系统版本',
  `app_version` VARCHAR(50) COMMENT '应用版本号',
  `screen_resolution` VARCHAR(50) COMMENT '屏幕分辨率',
  `network_type` VARCHAR(20) COMMENT '网络类型',
  `is_trusted` BOOLEAN DEFAULT FALSE COMMENT '是否信任设备',
  `trust_expire_time` DATETIME COMMENT '信任过期时间(默认30天)',
  `first_login_time` DATETIME COMMENT '首次登录时间',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `login_count` INT DEFAULT 0 COMMENT '登录次数统计',
  `last_login_ip` VARCHAR(50) COMMENT '最后登录IP',
  `last_login_location` VARCHAR(100) COMMENT '最后登录位置',
  `status` TINYINT DEFAULT 1 COMMENT '设备状态(0=已禁用,1=正常,2=异常)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户设备表-设备管理和信任设备';

-- ==========================================
-- 表4: phone_verify_limit (手机号验证限制表) - 9字段
-- ==========================================
-- 设计参考: PL.md 第594-620行
-- 功能: 防验证码穷举攻击、每日次数限制、自动封禁
-- 安全策略:
--   每日验证上限30次 | 每日发送上限10次 | 30次失败封禁24小时
-- ==========================================

DROP TABLE IF EXISTS `phone_verify_limit`;

CREATE TABLE `phone_verify_limit` (
  `mobile` VARCHAR(20) NOT NULL COMMENT '手机号(主键)',
  `daily_verify_count` INT DEFAULT 0 COMMENT '当日验证尝试总次数(所有验证码累计)',
  `daily_send_count` INT DEFAULT 0 COMMENT '当日发送短信总次数',
  `last_verify_time` DATETIME COMMENT '最后验证时间',
  `last_reset_date` DATE COMMENT '最后重置日期(每日0点重置计数)',
  `is_blocked` BOOLEAN DEFAULT FALSE COMMENT '是否被封禁',
  `block_until` DATETIME COMMENT '封禁截止时间(频繁失败封禁24小时)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`mobile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='手机号验证限制表-防验证码穷举攻击';

-- ==========================================
-- 表5: token_blacklist (JWT令牌黑名单表) - 7字段
-- ==========================================
-- 设计参考: PL.md 第568-591行
-- 功能: JWT令牌撤销、用户主动登出、远程注销、安全防护
-- 使用: 配合Redis使用，黑名单令牌存入Redis自动过期
-- ==========================================

DROP TABLE IF EXISTS `token_blacklist`;

CREATE TABLE `token_blacklist` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `token` VARCHAR(500) NOT NULL COMMENT '令牌字符串(唯一索引)',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `token_type` VARCHAR(20) NOT NULL COMMENT '令牌类型(access_token/refresh_token)',
  `reason` VARCHAR(50) COMMENT '加入黑名单原因(user_logout/admin_ban/security_issue/remote_logout)',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间(与原令牌过期时间一致,过期后自动清理)',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='JWT令牌黑名单表-支持令牌主动撤销';

-- ==========================================
-- 表结构创建完成
-- ==========================================
SELECT '✅ Alice认证模块 - 5张表创建完成！' AS status;

SHOW TABLES;

SELECT 
    TABLE_NAME AS '表名',
    TABLE_COMMENT AS '说明'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'xypai_auth'
ORDER BY TABLE_NAME;

-- ==========================================
-- 下一步: 执行 03_create_indexes.sql
-- ==========================================


-- ==========================================
-- Alice - 认证模块索引
-- ==========================================
-- 索引总数: 21个（5唯一 + 16普通）
-- 设计目标: 登录<200ms, Token验证<50ms
-- ==========================================

USE `xypai_auth`;

-- ==========================================
-- login_session 表索引（6个）
-- ==========================================

-- Token验证（高频：每次API调用）⭐
CREATE UNIQUE INDEX `uk_access_token` ON `login_session` (`access_token`);
CREATE UNIQUE INDEX `uk_refresh_token` ON `login_session` (`refresh_token`);

-- 用户会话查询（中频：会话管理页面）
CREATE INDEX `idx_user_status` ON `login_session` (`user_id`, `status`, `created_at`);

-- 设备查询（低频）
CREATE INDEX `idx_device` ON `login_session` (`device_id`, `user_id`, `status`);

-- 过期清理（定时任务）
CREATE INDEX `idx_expires` ON `login_session` (`expires_at`, `status`);

-- 心跳查询（高频）
CREATE INDEX `idx_last_active` ON `login_session` (`last_active_time`);

-- ==========================================
-- sms_verification 表索引（4个）
-- ==========================================

-- 防重放攻击（安全关键）⭐
CREATE UNIQUE INDEX `uk_sms_token` ON `sms_verification` (`sms_token`);

-- 验证码查询（高频：验证时）
CREATE INDEX `idx_mobile_type` ON `sms_verification` (`mobile`, `verification_type`, `verify_status`);

-- 过期清理（定时任务）
CREATE INDEX `idx_expire` ON `sms_verification` (`expire_time`);

-- 统计发送次数（中频）
CREATE INDEX `idx_send_time` ON `sms_verification` (`mobile`, `send_time`);

-- ==========================================
-- user_device 表索引（4个）
-- ==========================================

-- 防重复设备（唯一性保证）⭐
CREATE UNIQUE INDEX `uk_user_device` ON `user_device` (`user_id`, `device_id`);

-- 设备指纹识别（安全检测）
CREATE INDEX `idx_fingerprint` ON `user_device` (`device_fingerprint`);

-- 信任设备查询（中频）
CREATE INDEX `idx_trusted` ON `user_device` (`user_id`, `is_trusted`, `status`);

-- 清理不活跃设备（定时任务）
CREATE INDEX `idx_last_login` ON `user_device` (`last_login_time`);

-- ==========================================
-- phone_verify_limit 表索引（3个，含主键）
-- ==========================================

-- 主键已包含: mobile（快速查询限制状态）

-- 封禁查询（安全检查）
CREATE INDEX `idx_blocked` ON `phone_verify_limit` (`is_blocked`, `block_until`);

-- 每日重置（定时任务）
CREATE INDEX `idx_reset_date` ON `phone_verify_limit` (`last_reset_date`);

-- ==========================================
-- token_blacklist 表索引（4个）
-- ==========================================

-- 黑名单检查（高频：每次Token验证）⭐
CREATE UNIQUE INDEX `uk_token` ON `token_blacklist` (`token`);

-- 用户黑名单查询（低频）
CREATE INDEX `idx_user` ON `token_blacklist` (`user_id`, `created_at`);

-- 过期清理（定时任务）
CREATE INDEX `idx_expire` ON `token_blacklist` (`expire_time`);

-- 统计分析
CREATE INDEX `idx_token_type` ON `token_blacklist` (`token_type`, `created_at`);

-- ==========================================
-- 索引创建完成验证
-- ==========================================
SELECT '✅ Alice认证模块 - 21个索引创建完成！' AS status;

-- 显示所有索引
SELECT 
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名',
    COLUMN_NAME AS '字段',
    NON_UNIQUE AS '是否唯一(0=唯一)',
    INDEX_TYPE AS '索引类型'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'xypai_auth'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- 统计每张表的索引数
SELECT 
    TABLE_NAME AS '表名',
    COUNT(DISTINCT INDEX_NAME) AS '索引数量'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'xypai_auth'
GROUP BY TABLE_NAME;

-- ==========================================
-- 索引设计说明
-- ==========================================
-- 高频索引（QPS > 1000）:
--   • uk_access_token - Token验证，毫秒级响应
--   • uk_token - 黑名单检查，毫秒级响应
--   • mobile (PK) - 限制查询，毫秒级响应
--
-- 中频索引（QPS 100-1000）:
--   • idx_user_status - 用户会话列表
--   • idx_mobile_type - 验证码查询
--   • idx_trusted - 信任设备列表
--
-- 低频索引（定时任务）:
--   • idx_expires - 清理过期会话
--   • idx_expire - 清理过期验证码和黑名单
--   • idx_last_login - 清理不活跃设备
-- ==========================================

-- ==========================================
-- 下一步: 执行 04_init_test_data.sql
-- ==========================================


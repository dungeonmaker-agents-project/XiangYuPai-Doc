-- ==========================================
-- Alice - 认证模块定时任务（MySQL事件）
-- ==========================================
-- 功能: 自动清理过期数据、重置计数、解除封禁
-- 依赖: MySQL事件调度器
-- 启用: SET GLOBAL event_scheduler = ON;
-- ==========================================

USE `xypai_auth`;

-- ==========================================
-- 启用MySQL事件调度器
-- ==========================================
SET GLOBAL event_scheduler = ON;

-- ==========================================
-- 事件1: 每日0点重置验证限制
-- ==========================================
-- 功能: 重置daily_verify_count和daily_send_count为0
-- 执行: 每天00:00:00
-- 影响: 所有需要重置的记录（last_reset_date < 今天）

DROP EVENT IF EXISTS `reset_phone_verify_limit`;

CREATE EVENT `reset_phone_verify_limit`
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 00:00:00')
DO
    UPDATE `phone_verify_limit` 
    SET `daily_verify_count` = 0, 
        `daily_send_count` = 0, 
        `last_reset_date` = CURDATE(),
        `updated_at` = NOW()
    WHERE `last_reset_date` < CURDATE();

-- ==========================================
-- 事件2: 每日凌晨2点清理过期数据
-- ==========================================
-- 功能: 清理过期验证码、会话、黑名单，解除过期封禁
-- 执行: 每天02:00:00
-- 保留策略:
--   • 验证码: 30天
--   • 会话: 90天（status=0已过期）
--   • 黑名单: 自动清理expire_time < NOW()

DROP EVENT IF EXISTS `cleanup_expired_data`;

CREATE EVENT `cleanup_expired_data`
ON SCHEDULE EVERY 1 DAY
STARTS CONCAT(CURRENT_DATE + INTERVAL 1 DAY, ' 02:00:00')
DO BEGIN
    DECLARE sms_count INT DEFAULT 0;
    DECLARE session_count INT DEFAULT 0;
    DECLARE blacklist_count INT DEFAULT 0;
    DECLARE unblock_count INT DEFAULT 0;
    
    -- 1. 清理过期短信验证码（保留30天）
    DELETE FROM `sms_verification` 
    WHERE `expire_time` < DATE_SUB(NOW(), INTERVAL 30 DAY);
    SET sms_count = ROW_COUNT();
    
    -- 2. 清理过期会话（保留90天，仅清理已过期状态的）
    DELETE FROM `login_session` 
    WHERE `status` = 0 
      AND `created_at` < DATE_SUB(NOW(), INTERVAL 90 DAY);
    SET session_count = ROW_COUNT();
    
    -- 3. 清理过期Token黑名单
    DELETE FROM `token_blacklist` 
    WHERE `expire_time` < NOW();
    SET blacklist_count = ROW_COUNT();
    
    -- 4. 解除过期的封禁
    UPDATE `phone_verify_limit` 
    SET `is_blocked` = FALSE, 
        `block_until` = NULL,
        `updated_at` = NOW()
    WHERE `is_blocked` = TRUE 
      AND `block_until` < NOW();
    SET unblock_count = ROW_COUNT();
    
    -- 5. 记录清理结果（可选，输出到general_log）
    -- SELECT CONCAT('清理完成: 验证码=', sms_count, 
    --               ', 会话=', session_count, 
    --               ', 黑名单=', blacklist_count,
    --               ', 解除封禁=', unblock_count) AS cleanup_result;
END;

-- ==========================================
-- 事件3: 每周日凌晨3点优化表
-- ==========================================
-- 功能: 更新表统计信息，优化查询性能
-- 执行: 每周日03:00:00

DROP EVENT IF EXISTS `optimize_tables_weekly`;

CREATE EVENT `optimize_tables_weekly`
ON SCHEDULE EVERY 1 WEEK
STARTS DATE_ADD(DATE_ADD(CURDATE(), INTERVAL (7 - DAYOFWEEK(CURDATE())) DAY), INTERVAL '03:00:00' HOUR_SECOND)
DO BEGIN
    -- 分析表，更新统计信息
    ANALYZE TABLE `login_session`;
    ANALYZE TABLE `sms_verification`;
    ANALYZE TABLE `user_device`;
    ANALYZE TABLE `phone_verify_limit`;
    ANALYZE TABLE `token_blacklist`;
    
    -- 优化表（可选，会锁表）
    -- OPTIMIZE TABLE `sms_verification`;
END;

-- ==========================================
-- 查看已创建的事件
-- ==========================================
SELECT 
    EVENT_NAME AS '事件名',
    EVENT_DEFINITION AS '执行SQL',
    INTERVAL_VALUE AS '间隔',
    INTERVAL_FIELD AS '单位',
    STARTS AS '开始时间',
    STATUS AS '状态'
FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'xypai_auth'
ORDER BY EVENT_NAME;

-- ==========================================
-- 验证事件调度器状态
-- ==========================================
SHOW VARIABLES LIKE 'event_scheduler';
-- 应该显示: ON

-- ==========================================
-- 手动测试事件（可选）
-- ==========================================
-- 测试重置验证限制:
-- CALL reset_phone_verify_limit;

-- 测试清理过期数据:
-- CALL cleanup_expired_data;

-- ==========================================
-- 禁用/启用事件（管理）
-- ==========================================
-- 禁用单个事件:
-- ALTER EVENT reset_phone_verify_limit DISABLE;

-- 启用单个事件:
-- ALTER EVENT reset_phone_verify_limit ENABLE;

-- 删除事件:
-- DROP EVENT IF EXISTS reset_phone_verify_limit;

-- ==========================================
-- 使用说明
-- ==========================================
-- 1. 首次执行需要启用事件调度器:
--    SET GLOBAL event_scheduler = ON;
--    （或在my.cnf中配置: event_scheduler = ON）
--
-- 2. 执行本脚本创建3个定时事件
--
-- 3. 验证事件是否创建成功:
--    SELECT * FROM information_schema.EVENTS 
--    WHERE EVENT_SCHEMA = 'xypai_auth';
--
-- 4. 查看事件执行历史（需要开启general_log）:
--    SET GLOBAL general_log = ON;
--    tail -f /var/log/mysql/mysql.log
-- ==========================================


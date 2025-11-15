-- ==========================================
-- Alice - 认证模块测试数据
-- ==========================================
-- 数据量: 31条记录（10设备 + 7会话 + 5验证码 + 5限制 + 4黑名单）
-- 用途: 开发和测试环境
-- 关联: 使用dev_workspace创建的10个测试用户(1001-1010)
-- ==========================================

USE `xypai_auth`;

-- ==========================================
-- 1. 用户设备数据（10条）
-- ==========================================
-- 关联用户: Alice(1001), Bob(1002), Charlie(1003), Diana(1004), Erik(1005), Fiona(1006)

INSERT INTO `user_device` (
    `id`, `user_id`, `device_id`, `device_name`, `device_type`, 
    `device_brand`, `device_model`, `os_type`, `os_version`, `app_version`,
    `is_trusted`, `trust_expire_time`, `first_login_time`, `last_login_time`, 
    `login_count`, `last_login_ip`, `last_login_location`, `status`
) VALUES
-- Alice的3个设备
(1, 1001, 'alice_iphone_13pro', 'Alice的iPhone 13 Pro', 'iOS', 
 'Apple', 'iPhone 13 Pro', 'iOS', '17.2.1', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-01 08:00:00', NOW(), 
 156, '120.244.xxx.123', '北京 朝阳区', 1),

(2, 1001, 'alice_macbook_pro', 'Alice的MacBook Pro', 'Web', 
 'Apple', 'MacBook Pro 16"', 'macOS', '14.1', 'Chrome 120',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-05 09:00:00', NOW(), 
 89, '120.244.xxx.123', '北京 朝阳区', 1),

(3, 1001, 'alice_ipad_air', 'Alice的iPad Air', 'iOS', 
 'Apple', 'iPad Air', 'iPadOS', '17.2', 'v1.0.0',
 FALSE, NULL, '2024-12-20 20:00:00', '2024-12-27 21:00:00', 
 12, '120.244.xxx.124', '北京 朝阳区', 1),

-- Bob的2个设备
(4, 1002, 'bob_samsung_s23', 'Bob的三星S23', 'Android', 
 'Samsung', 'Galaxy S23 Ultra', 'Android', '14.0', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-03 10:00:00', NOW(), 
 98, '121.230.xxx.101', '上海 浦东新区', 1),

(5, 1002, 'bob_windows_pc', 'Bob的Windows PC', 'Web', 
 'Dell', 'XPS 15', 'Windows', '11', 'Chrome 120',
 FALSE, NULL, '2024-12-15 14:00:00', '2024-12-28 16:00:00', 
 34, '121.230.xxx.102', '上海 浦东新区', 1),

-- Charlie/Diana/Erik/Fiona的设备
(6, 1003, 'charlie_xiaomi_13', 'Charlie的小米13', 'Android', 
 'Xiaomi', 'Xiaomi 13', 'Android', '13.0', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-10 09:00:00', NOW(), 
 67, '60.180.xxx.88', '杭州 西湖区', 1),

(7, 1004, 'diana_iphone_14', 'Diana的iPhone 14', 'iOS', 
 'Apple', 'iPhone 14 Pro', 'iOS', '17.1', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-08 07:30:00', NOW(), 
 112, '14.120.xxx.56', '深圳 南山区', 1),

(8, 1004, 'diana_ipad_pro', 'Diana的iPad Pro', 'iOS', 
 'Apple', 'iPad Pro 12.9"', 'iPadOS', '17.1', 'v1.0.0',
 FALSE, NULL, '2024-12-22 19:00:00', '2024-12-28 22:00:00', 
 18, '14.120.xxx.57', '深圳 南山区', 1),

(9, 1005, 'erik_huawei_p60', 'Erik的华为P60', 'Android', 
 'Huawei', 'P60 Pro', 'HarmonyOS', '4.0', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-12 11:00:00', NOW(), 
 78, '182.150.xxx.77', '成都 高新区', 1),

(10, 1006, 'fiona_iphone_15', 'Fiona的iPhone 15', 'iOS', 
 'Apple', 'iPhone 15', 'iOS', '17.2', 'v1.0.0',
 TRUE, DATE_ADD(NOW(), INTERVAL 30 DAY), '2024-12-06 08:30:00', NOW(), 
 134, '113.110.xxx.200', '广州 天河区', 1);

-- ==========================================
-- 2. 活跃登录会话（5条活跃 + 2条历史）
-- ==========================================

INSERT INTO `login_session` (
    `id`, `user_id`, `device_id`, `access_token`, `refresh_token`, 
    `token_type`, `expires_at`, `refresh_expires_at`, `login_type`, 
    `login_ip`, `login_location`, `device_type`, `device_name`, 
    `os_type`, `is_trusted_device`, `last_active_time`, `status`, `created_at`
) VALUES
-- 活跃会话
(1001, 1001, 'alice_iphone_13pro', 'test_access_alice_001', 'test_refresh_alice_001', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 20 HOUR), DATE_ADD(NOW(), INTERVAL 6 DAY), 1,
 '120.244.xxx.123', '北京 朝阳区', 'iOS', 'Alice的iPhone 13 Pro', 'iOS',
 TRUE, NOW(), 1, DATE_SUB(NOW(), INTERVAL 4 HOUR)),

(1002, 1001, 'alice_macbook_pro', 'test_access_alice_002', 'test_refresh_alice_002', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 22 HOUR), DATE_ADD(NOW(), INTERVAL 6 DAY), 1,
 '120.244.xxx.123', '北京 朝阳区', 'Web', 'MacBook Pro', 'macOS',
 TRUE, NOW(), 1, DATE_SUB(NOW(), INTERVAL 2 HOUR)),

(1003, 1002, 'bob_samsung_s23', 'test_access_bob_001', 'test_refresh_bob_001', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 18 HOUR), DATE_ADD(NOW(), INTERVAL 5 DAY), 2,
 '121.230.xxx.101', '上海 浦东新区', 'Android', '三星S23', 'Android',
 TRUE, NOW(), 1, DATE_SUB(NOW(), INTERVAL 6 HOUR)),

(1004, 1003, 'charlie_xiaomi_13', 'test_access_charlie_001', 'test_refresh_charlie_001', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 23 HOUR), DATE_ADD(NOW(), INTERVAL 6 DAY), 2,
 '60.180.xxx.88', '杭州 西湖区', 'Android', '小米13', 'Android',
 TRUE, NOW(), 1, DATE_SUB(NOW(), INTERVAL 1 HOUR)),

(1005, 1004, 'diana_iphone_14', 'test_access_diana_001', 'test_refresh_diana_001', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 21 HOUR), DATE_ADD(NOW(), INTERVAL 6 DAY), 1,
 '14.120.xxx.56', '深圳 南山区', 'iOS', 'iPhone 14', 'iOS',
 TRUE, NOW(), 1, DATE_SUB(NOW(), INTERVAL 3 HOUR)),

-- 历史会话（已过期/已注销）
(2001, 1001, 'alice_old_device', 'expired_token_001', 'expired_refresh_001', 
 'Bearer', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 1,
 '120.244.xxx.120', '北京', 'iOS', 'Old iPhone', 'iOS',
 FALSE, DATE_SUB(NOW(), INTERVAL 2 DAY), 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),

(2002, 1002, 'bob_old_pc', 'revoked_token_001', 'revoked_refresh_001', 
 'Bearer', DATE_ADD(NOW(), INTERVAL 12 HOUR), DATE_ADD(NOW(), INTERVAL 5 DAY), 1,
 '121.230.xxx.100', '上海', 'Web', 'Old PC', 'Windows',
 FALSE, DATE_SUB(NOW(), INTERVAL 1 DAY), 2, DATE_SUB(NOW(), INTERVAL 1 DAY));

-- ==========================================
-- 3. 短信验证码历史（5条）
-- ==========================================

INSERT INTO `sms_verification` (
    `id`, `mobile`, `region_code`, `sms_code`, `sms_token`, 
    `verification_type`, `scene`, `template_code`, 
    `send_status`, `verify_status`, `verify_count`, 
    `ip_address`, `device_id`, `send_time`, `expire_time`, `verify_time`
) VALUES
(1, '13800138001', '+86', '123456', 'smstoken_success_001', 
 1, 'user_login', 'SMS_LOGIN_CODE', 
 1, 1, 1, 
 '120.244.xxx.123', 'alice_iphone_13pro', 
 DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),

(2, '13800138002', '+86', '234567', 'smstoken_success_002', 
 1, 'user_login', 'SMS_LOGIN_CODE', 
 1, 1, 1, 
 '121.230.xxx.101', 'bob_samsung_s23', 
 DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),

(3, '13900139000', '+86', '111111', 'smstoken_failed_003', 
 1, 'user_login', 'SMS_LOGIN_CODE', 
 1, 2, 3, 
 '192.168.1.100', 'unknown_device', 
 DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),

(4, '13800138003', '+86', '345678', 'smstoken_expired_004', 
 1, 'user_login', 'SMS_LOGIN_CODE', 
 1, 3, 0, 
 '60.180.xxx.88', 'charlie_xiaomi_13', 
 DATE_SUB(NOW(), INTERVAL 10 MINUTE), DATE_SUB(NOW(), INTERVAL 5 MINUTE), NULL),

(5, '13800138004', '+86', '456789', 'smstoken_pending_005', 
 1, 'user_login', 'SMS_LOGIN_CODE', 
 1, 0, 0, 
 '14.120.xxx.56', 'diana_iphone_14', 
 NOW(), DATE_ADD(NOW(), INTERVAL 5 MINUTE), NULL);

-- ==========================================
-- 4. 手机号验证限制（5条）
-- ==========================================

INSERT INTO `phone_verify_limit` (
    `mobile`, `daily_verify_count`, `daily_send_count`, 
    `last_verify_time`, `last_reset_date`, `is_blocked`, `block_until`
) VALUES
('13800138001', 2, 1, NOW(), CURDATE(), FALSE, NULL),
('13800138002', 3, 2, NOW(), CURDATE(), FALSE, NULL),
('13800138003', 1, 1, NOW(), CURDATE(), FALSE, NULL),
('13900139001', 25, 8, NOW(), CURDATE(), FALSE, NULL),  -- 接近上限
('13900139999', 30, 10, DATE_SUB(NOW(), INTERVAL 1 HOUR), CURDATE(), 
 TRUE, DATE_ADD(NOW(), INTERVAL 23 HOUR));  -- 已封禁

-- ==========================================
-- 5. Token黑名单（4条）
-- ==========================================

INSERT INTO `token_blacklist` (
    `id`, `token`, `user_id`, `token_type`, `reason`, `expire_time`
) VALUES
(1, 'blacklist_token_001', 1001, 'access_token', 'user_logout', DATE_ADD(NOW(), INTERVAL 2 HOUR)),
(2, 'blacklist_token_002', 1002, 'access_token', 'remote_logout', DATE_ADD(NOW(), INTERVAL 5 HOUR)),
(3, 'blacklist_token_003', 9999, 'access_token', 'admin_ban', DATE_ADD(NOW(), INTERVAL 1 DAY)),
(4, 'blacklist_token_004', 1005, 'access_token', 'security_issue', DATE_ADD(NOW(), INTERVAL 3 HOUR));

-- ==========================================
-- 数据验证
-- ==========================================
SELECT '✅ Alice认证模块 - 测试数据初始化完成！' AS status;

-- 统计各表记录数
SELECT 'user_device' AS '表名', COUNT(*) AS '记录数' FROM user_device
UNION ALL
SELECT 'login_session', COUNT(*) FROM login_session
UNION ALL
SELECT 'sms_verification', COUNT(*) FROM sms_verification
UNION ALL
SELECT 'phone_verify_limit', COUNT(*) FROM phone_verify_limit
UNION ALL
SELECT 'token_blacklist', COUNT(*) FROM token_blacklist;

-- 查看活跃会话
SELECT 
    user_id AS '用户ID',
    device_name AS '设备',
    login_type AS '登录方式',
    login_location AS '位置',
    status AS '状态',
    created_at AS '登录时间'
FROM login_session
WHERE status = 1
ORDER BY created_at DESC;

-- 查看信任设备
SELECT 
    user_id AS '用户ID',
    device_name AS '设备',
    login_count AS '登录次数',
    CASE WHEN is_trusted THEN '信任设备' ELSE '普通设备' END AS '设备类型'
FROM user_device
WHERE is_trusted = TRUE
ORDER BY login_count DESC;

-- ==========================================
-- 测试场景说明
-- ==========================================
-- 1. 多设备登录: Alice有3个设备（iPhone+MacBook+iPad）
-- 2. 活跃会话: 5个用户当前在线
-- 3. 验证码状态: 成功/失败/过期/待验证 4种状态
-- 4. 防穷举测试: 13900139001接近上限，13900139999已封禁
-- 5. Token黑名单: 4种不同原因（登出/远程注销/封禁/安全）
--
-- 可用于测试:
-- ✅ 多设备管理
-- ✅ 会话查询和注销
-- ✅ 信任设备功能
-- ✅ 短信防刷机制
-- ✅ 验证码穷举防护
-- ✅ Token黑名单验证
-- ==========================================


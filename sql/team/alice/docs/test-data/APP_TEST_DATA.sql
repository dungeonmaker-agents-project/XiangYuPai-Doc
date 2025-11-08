-- ==========================================
-- APP测试数据 - 一键安装脚本
-- ==========================================
-- 功能: 创建完整的APP测试账号及相关数据
-- 账号: app_tester / Test@123456
-- 手机: 13900000001
-- 用户ID: 2000
-- ==========================================
-- 使用方法:
--   方法1: mysql -u root -p < APP_TEST_DATA.sql
--   方法2: 在 MySQL Workbench/Navicat 中直接执行
-- ==========================================
-- 数据库架构: 基于 Bob 的 xypai_user 设计
-- ==========================================

-- ==========================================
-- 第一部分: 清理旧数据 (确保环境干净)
-- ==========================================

-- 清理 ry-cloud 数据库中的旧权限数据
USE `ry-cloud`;
DELETE FROM `sys_user_role` WHERE user_id = 2000;
DELETE FROM `sys_role_menu` WHERE role_id = 10;
DELETE FROM `sys_role` WHERE role_id = 10;
DELETE FROM `sys_menu` WHERE menu_id IN (20001, 20002, 20003, 20004);

SELECT '✅ ry-cloud 旧权限数据清理完成' AS status;

-- 清理 xypai_auth 数据库中的旧数据
USE `xypai_auth`;
DELETE FROM `login_session` WHERE user_id = 2000;
DELETE FROM `sms_verification` WHERE mobile = '13900000001';
DELETE FROM `phone_verify_limit` WHERE mobile = '13900000001';
DELETE FROM `user_device` WHERE user_id = 2000;

SELECT '✅ xypai_auth 旧数据清理完成' AS status;

-- 清理 xypai_user 数据库中的旧数据
USE `xypai_user`;
DELETE FROM `user_occupation` WHERE user_id = 2000;
DELETE FROM `user_wallet` WHERE user_id = 2000;
DELETE FROM `user_stats` WHERE user_id = 2000;
DELETE FROM `user_profile` WHERE user_id = 2000;
DELETE FROM `user` WHERE id = 2000;

SELECT '✅ xypai_user 旧数据清理完成' AS status;
SELECT '' AS '';

-- ==========================================
-- 第二部分: 创建测试用户 (xypai_user 数据库)
-- ==========================================

USE `xypai_user`;

-- 1. 创建用户基础信息
-- 密码: Test@123456 (BCrypt加密)
-- 支持: 用户名登录(app_tester) 或 手机号登录(13900000001)
INSERT INTO `user` (
    `id`,
    `username`,
    `mobile`,
    `region_code`,
    `email`,
    `password`,
    `password_salt`,
    `password_updated_at`,
    `status`,
    `login_fail_count`,
    `login_locked_until`,
    `last_login_time`,
    `last_login_ip`,
    `last_login_device_id`,
    `is_two_factor_enabled`,
    `two_factor_secret`,
    `created_at`,
    `updated_at`,
    `deleted`,
    `version`
) VALUES (
    2000,
    'app_tester',
    '13900000001',
    '+86',
    'app_tester@xypai.com',
    '$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe',
    'salt_app_test',
    NOW(),
    1,
    0,
    NULL,
    NOW(),
    '127.0.0.1',
    'test_device_001',
    FALSE,
    NULL,
    NOW(),
    NOW(),
    0,
    0
) ON DUPLICATE KEY UPDATE
    `username` = 'app_tester',
    `mobile` = '13900000001',
    `password` = '$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe',
    `status` = 1,
    `deleted` = 0,
    `updated_at` = NOW();
# Test@123456
SELECT '✅ 用户基础信息创建成功' AS status;

-- 2. 创建用户资料
INSERT INTO `user_profile` (
    `user_id`,
    `nickname`,
    `avatar`,
    `avatar_thumbnail`,
    `background_image`,
    `gender`,
    `birthday`,
    `age`,
    `city_id`,
    `location`,
    `address`,
    `ip_location`,
    `bio`,
    `height`,
    `weight`,
    `real_name`,
    `id_card_encrypted`,
    `wechat`,
    `wechat_unlock_condition`,
    `is_real_verified`,
    `is_god_verified`,
    `is_activity_expert`,
    `is_vip`,
    `is_popular`,
    `vip_level`,
    `vip_expire_time`,
    `online_status`,
    `last_online_time`,
    `profile_completeness`,
    `last_edit_time`,
    `deleted_at`,
    `created_at`,
    `updated_at`,
    `version`
) VALUES (
    2000,
    'APP测试员',
    'https://picsum.photos/200?test',
    'https://picsum.photos/100?test',
    'https://picsum.photos/800/400?test',
    0,
    '1995-01-01',
    30,
    110100,
    '北京 海淀区',
    '中关村软件园',
    '北京',
    'APP前端测试专用账号，用于开发调试',
    175,
    70,
    NULL,
    NULL,
    'app_tester_wx',
    0,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    0,
    NULL,
    1,
    NOW(),
    85,
    NOW(),
    NULL,
    NOW(),
    NOW(),
    0
) ON DUPLICATE KEY UPDATE
    `nickname` = 'APP测试员',
    `online_status` = 1,
    `last_online_time` = NOW(),
    `updated_at` = NOW();

SELECT '✅ 用户资料创建成功' AS status;

-- 3. 创建用户统计数据
INSERT INTO `user_stats` (
    `user_id`,
    `follower_count`,
    `following_count`,
    `content_count`,
    `total_like_count`,
    `total_collect_count`,
    `activity_organizer_count`,
    `activity_participant_count`,
    `activity_success_count`,
    `activity_cancel_count`,
    `activity_organizer_score`,
    `activity_success_rate`,
    `last_sync_time`,
    `updated_at`
) VALUES (
    2000,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0.00,
    0.00,
    NOW(),
    NOW()
) ON DUPLICATE KEY UPDATE
    `last_sync_time` = NOW(),
    `updated_at` = NOW();

SELECT '✅ 用户统计数据创建成功' AS status;

-- 4. 创建用户钱包
INSERT INTO `user_wallet` (
    `user_id`,
    `balance`,
    `frozen`,
    `coin_balance`,
    `total_income`,
    `total_expense`,
    `version`,
    `updated_at`
) VALUES (
    2000,
    0,
    0,
    0,
    0,
    0,
    0,
    NOW()
) ON DUPLICATE KEY UPDATE
    `updated_at` = NOW();

SELECT '✅ 用户钱包创建成功' AS status;

-- 5. 添加测试用户职业标签（可选）
INSERT INTO `user_occupation` (`user_id`, `occupation_code`, `sort_order`, `created_at`)
VALUES (2000, 'programmer', 0, NOW())
ON DUPLICATE KEY UPDATE `sort_order` = 0;

SELECT '✅ 用户职业标签创建成功' AS status;

-- ==========================================
-- 第二部分: 创建设备和认证数据 (xypai_auth 数据库)
-- ==========================================

USE `xypai_auth`;

-- 1. 创建测试设备记录
INSERT INTO `user_device` (
    `id`,
    `user_id`,
    `device_id`,
    `device_fingerprint`,
    `device_name`,
    `device_type`,
    `device_brand`,
    `device_model`,
    `os_type`,
    `os_version`,
    `app_version`,
    `screen_resolution`,
    `network_type`,
    `is_trusted`,
    `trust_expire_time`,
    `first_login_time`,
    `last_login_time`,
    `login_count`,
    `last_login_ip`,
    `last_login_location`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    9001,
    2000,
    'test_device_001',
    'fp_test_device_001',
    'APP测试设备',
    'iOS',
    'Apple',
    'iPhone 14 Pro',
    'iOS',
    '17.2',
    'v1.0.0',
    '1179x2556',
    'WiFi',
    TRUE,
    DATE_ADD(NOW(), INTERVAL 30 DAY),
    DATE_SUB(NOW(), INTERVAL 7 DAY),
    NOW(),
    25,
    '127.0.0.1',
    '本地测试',
    1,
    DATE_SUB(NOW(), INTERVAL 7 DAY),
    NOW()
) ON DUPLICATE KEY UPDATE
    `last_login_time` = NOW(),
    `login_count` = `login_count` + 1,
    `status` = 1,
    `updated_at` = NOW();

SELECT '✅ 设备创建成功' AS status;

-- 2. 创建手机号验证限制记录
INSERT INTO `phone_verify_limit` (
    `mobile`,
    `daily_verify_count`,
    `daily_send_count`,
    `last_verify_time`,
    `last_reset_date`,
    `is_blocked`,
    `block_until`,
    `created_at`,
    `updated_at`
) VALUES (
    '13900000001',
    0,
    0,
    NULL,
    CURDATE(),
    FALSE,
    NULL,
    NOW(),
    NOW()
) ON DUPLICATE KEY UPDATE
    `daily_verify_count` = 0,
    `daily_send_count` = 0,
    `last_reset_date` = CURDATE(),
    `is_blocked` = FALSE,
    `block_until` = NULL,
    `updated_at` = NOW();

SELECT '✅ 验证限制初始化成功' AS status;

-- 3. 创建历史短信验证码记录 (示例)
INSERT INTO `sms_verification` (
    `id`,
    `mobile`,
    `region_code`,
    `sms_code`,
    `sms_token`,
    `verification_type`,
    `scene`,
    `template_code`,
    `send_status`,
    `verify_status`,
    `verify_count`,
    `max_verify_count`,
    `ip_address`,
    `device_id`,
    `send_time`,
    `expire_time`,
    `verify_time`,
    `created_at`
) VALUES (
    9001,
    '13900000001',
    '+86',
    '888888',
    'sms_token_test_001',
    1,
    'user_login',
    'SMS_LOGIN_CODE',
    1,
    1,
    1,
    3,
    '127.0.0.1',
    'test_device_001',
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    DATE_SUB(NOW(), INTERVAL 2 DAY),
    DATE_SUB(NOW(), INTERVAL 2 DAY)
) ON DUPLICATE KEY UPDATE
    `verify_status` = 1;

SELECT '✅ 验证码记录创建成功' AS status;

-- 4. 创建活跃登录会话 (示例)
INSERT INTO `login_session` (
    `id`,
    `user_id`,
    `device_id`,
    `access_token`,
    `refresh_token`,
    `token_type`,
    `expires_at`,
    `refresh_expires_at`,
    `login_type`,
    `login_ip`,
    `login_location`,
    `user_agent`,
    `device_type`,
    `device_name`,
    `os_type`,
    `os_version`,
    `app_version`,
    `network_type`,
    `is_trusted_device`,
    `last_active_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    9001,
    2000,
    'test_device_001',
    'test_access_token_app_tester_001',
    'test_refresh_token_app_tester_001',
    'Bearer',
    DATE_ADD(NOW(), INTERVAL 2 HOUR),
    DATE_ADD(NOW(), INTERVAL 7 DAY),
    1,
    '127.0.0.1',
    '本地测试',
    'XYPai-RNExpoAPP/1.0.0',
    'iOS',
    'APP测试设备',
    'iOS',
    '17.2',
    'v1.0.0',
    'WiFi',
    TRUE,
    NOW(),
    1,
    DATE_SUB(NOW(), INTERVAL 1 HOUR),
    NOW()
) ON DUPLICATE KEY UPDATE
    `status` = 1,
    `last_active_time` = NOW(),
    `updated_at` = NOW();

SELECT '✅ 登录会话创建成功' AS status;

-- ==========================================
-- 第三部分: 配置用户权限 (ry-cloud 数据库)
-- ==========================================

USE `ry-cloud`;

-- 1. 创建 "APP用户" 角色
INSERT INTO `sys_role` (
    `role_id`,
    `tenant_id`,
    `role_name`,
    `role_key`,
    `role_sort`,
    `data_scope`,
    `menu_check_strictly`,
    `dept_check_strictly`,
    `status`,
    `del_flag`,
    `create_dept`,
    `create_by`,
    `create_time`,
    `update_by`,
    `update_time`,
    `remark`
) VALUES (
    10,
    '000000',
    'APP用户',
    'app_user',
    10,
    '5',
    1,
    1,
    '0',
    '0',
    103,
    1,
    NOW(),
    NULL,
    NULL,
    'APP端普通用户角色，拥有查看个人资料等基础权限'
) ON DUPLICATE KEY UPDATE
    `role_name` = 'APP用户',
    `status` = '0',
    `del_flag` = '0',
    `updated_at` = NOW();

SELECT '✅ APP用户角色创建成功' AS status;

-- 2. 创建用户资料相关权限菜单项
INSERT INTO `sys_menu` VALUES 
('20001', '用户资料管理', '5', '1', 'user-profile', null, '', 1, 0, 'M', '0', '0', '', 'user', 103, 1, NOW(), null, null, '用户资料模块'),
('20002', '查询用户资料', '20001', '1', '#', '', '', 1, 0, 'F', '0', '0', 'user:profile:query', '#', 103, 1, NOW(), NULL, NULL, '查询用户资料权限'),
('20003', '更新用户资料', '20001', '2', '#', '', '', 1, 0, 'F', '0', '0', 'user:profile:edit', '#', 103, 1, NOW(), NULL, NULL, '更新用户资料权限'),
('20004', '查询资料完整度', '20001', '3', '#', '', '', 1, 0, 'F', '0', '0', 'user:profile:completeness', '#', 103, 1, NOW(), NULL, NULL, '查询资料完整度权限')
ON DUPLICATE KEY UPDATE
    `status` = '0',
    `del_flag` = '0';

SELECT '✅ 用户资料权限菜单创建成功' AS status;

-- 3. 将权限分配给 "APP用户" 角色
INSERT INTO `sys_role_menu` VALUES 
('10', '20001'),
('10', '20002'),
('10', '20003'),
('10', '20004')
ON DUPLICATE KEY UPDATE
    `role_id` = VALUES(`role_id`);

SELECT '✅ 权限分配给角色成功' AS status;

-- 4. 将测试用户分配到 "APP用户" 角色
INSERT INTO `sys_user_role` VALUES 
('2000', '10')
ON DUPLICATE KEY UPDATE
    `role_id` = '10';

SELECT '✅ 用户角色绑定成功' AS status;

-- ==========================================
-- 安装完成 - 数据验证
-- ==========================================

SELECT '' AS '';
SELECT '═══════════════════════════════════════════════════════' AS '═══════════════════════════════════════════════════════';
SELECT '🎉 APP测试数据安装完成！' AS '';
SELECT '═══════════════════════════════════════════════════════' AS '═══════════════════════════════════════════════════════';
SELECT '' AS '';

-- 显示测试账号信息
SELECT '📱 测试账号信息' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
USE `xypai_user`;
SELECT
    u.id AS '用户ID',
    u.username AS '用户名',
    p.nickname AS '昵称',
    u.mobile AS '手机号',
    CASE u.status
        WHEN 1 THEN '✅ 正常'
        WHEN 0 THEN '❌ 禁用'
        WHEN 2 THEN '⚠️ 冻结'
        ELSE '❓ 未知'
    END AS '状态',
    p.profile_completeness AS '资料完整度(%)',
    u.created_at AS '创建时间'
FROM `user` u
LEFT JOIN `user_profile` p ON u.id = p.user_id
WHERE u.id = 2000;

SELECT '' AS '';
SELECT '🔐 登录凭证' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
SELECT '13900000001' AS '用户名(手机号)';
SELECT 'Test@123456' AS '密码';
SELECT '13900000001' AS '手机号';
SELECT '' AS '';

-- 显示设备信息
SELECT '📱 设备信息' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
USE `xypai_auth`;
SELECT
    device_id AS '设备ID',
    device_name AS '设备名称',
    device_type AS '类型',
    CASE is_trusted WHEN TRUE THEN '✅ 是' ELSE '❌ 否' END AS '是否信任',
    login_count AS '登录次数',
    last_login_time AS '最后登录'
FROM user_device
WHERE user_id = 2000;

SELECT '' AS '';
SELECT '📊 用户统计数据' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
USE `xypai_user`;
SELECT
    follower_count AS '粉丝数',
    following_count AS '关注数',
    content_count AS '内容数',
    total_like_count AS '获赞数',
    activity_organizer_count AS '组局数',
    activity_participant_count AS '参与数'
FROM user_stats
WHERE user_id = 2000;

SELECT '' AS '';
SELECT '💰 用户钱包' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
SELECT
    CONCAT(balance / 100, ' 元') AS '可用余额',
    CONCAT(frozen / 100, ' 元') AS '冻结金额',
    coin_balance AS '金币余额',
    CONCAT(total_income / 100, ' 元') AS '累计收入',
    CONCAT(total_expense / 100, ' 元') AS '累计支出'
FROM user_wallet
WHERE user_id = 2000;

SELECT '' AS '';
SELECT '📊 验证限制状态' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
USE `xypai_auth`;
SELECT
    mobile AS '手机号',
    daily_verify_count AS '今日验证次数',
    daily_send_count AS '今日发送次数',
    CASE is_blocked WHEN FALSE THEN '✅ 正常' ELSE '❌ 已封禁' END AS '状态',
    last_reset_date AS '重置日期'
FROM phone_verify_limit
WHERE mobile = '13900000001';

SELECT '' AS '';
SELECT '💻 活跃会话' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
SELECT
    device_name AS '设备',
    CASE login_type WHEN 1 THEN '密码登录' WHEN 2 THEN '验证码登录' ELSE '其他' END AS '登录方式',
    CASE status WHEN 1 THEN '✅ 正常' ELSE '❌ 已过期' END AS '状态',
    expires_at AS '过期时间'
FROM login_session
WHERE user_id = 2000 AND status = 1;

SELECT '' AS '';
SELECT '🔐 用户权限信息' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
USE `ry-cloud`;
SELECT
    r.role_name AS '角色名称',
    r.role_key AS '角色标识',
    CASE r.status WHEN '0' THEN '✅ 正常' ELSE '❌ 停用' END AS '状态'
FROM sys_user_role ur
LEFT JOIN sys_role r ON ur.role_id = r.role_id
WHERE ur.user_id = 2000;

SELECT '' AS '';
SELECT '📋 角色权限列表' AS '';
SELECT '───────────────────────────────────────────────────────' AS '───────────────────────────────────────────────────────';
SELECT
    m.menu_name AS '权限名称',
    m.perms AS '权限标识',
    CASE m.menu_type 
        WHEN 'M' THEN '目录' 
        WHEN 'C' THEN '菜单' 
        WHEN 'F' THEN '按钮/功能' 
        ELSE '未知' 
    END AS '类型'
FROM sys_role_menu rm
LEFT JOIN sys_menu m ON rm.menu_id = m.menu_id
WHERE rm.role_id = 10
ORDER BY m.menu_id;

SELECT '' AS '';
SELECT '═══════════════════════════════════════════════════════' AS '═══════════════════════════════════════════════════════';
SELECT '🚀 快速测试' AS '';
SELECT '═══════════════════════════════════════════════════════' AS '═══════════════════════════════════════════════════════';
SELECT '' AS '';
SELECT 'POST http://localhost:8080/xypai-auth/api/v1/auth/login' AS 'API地址';
SELECT '' AS '';
SELECT '请求Body (JSON):' AS '';
SELECT '{' AS '';
SELECT '  "username": "13900000001",' AS '';
SELECT '  "password": "Test@123456",' AS '';
SELECT '  "clientType": "app",' AS '';
SELECT '  "deviceId": "test_device_001"' AS '';
SELECT '}' AS '';
SELECT '' AS '';
SELECT '📖 详细文档: xypai-security/test-data/APP_TEST_ACCOUNT.md' AS '';
SELECT '📚 API文档: http://localhost:8080/xypai-auth/doc.html' AS '';
SELECT '' AS '';
SELECT '✨ 现在可以开始APP前后端联调了！' AS '';
SELECT '═══════════════════════════════════════════════════════' AS '═══════════════════════════════════════════════════════';


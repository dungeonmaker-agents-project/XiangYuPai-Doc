-- ==========================================
-- 更新测试数据（适配新架构）
-- ==========================================
-- 目标: 确保测试账号在 xypai_auth.user 中存在
-- 用途: 升级完成后的测试验证
-- ==========================================

USE `xypai_auth`;

-- ==========================================
-- 第一步：清理旧测试数据
-- ==========================================

SELECT '🧹 清理旧测试数据...' AS step;

-- 删除测试账号的所有会话
DELETE FROM `login_session` WHERE user_id = 2000;

-- 删除测试手机号的所有短信验证记录
DELETE FROM `sms_verification` WHERE mobile = '13900000001';

-- 删除测试手机号的验证限制记录
DELETE FROM `phone_verify_limit` WHERE mobile = '13900000001';

-- 删除测试账号的设备记录
DELETE FROM `user_device` WHERE user_id = 2000;

-- 删除测试账号的认证数据
DELETE FROM `user` WHERE id = 2000;

SELECT '✅ 旧测试数据已清理' AS status;

-- ==========================================
-- 第二步：创建测试账号（认证域）
-- ==========================================

SELECT '📝 创建测试账号...' AS step;

-- 插入测试用户认证数据
-- 用户ID: 2000
-- 用户名: app_tester
-- 手机号: 13900000001
-- 密码: Test@123456（BCrypt哈希）
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
    '$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe',  -- BCrypt(Test@123456)
    NULL,
    NOW(),
    1,  -- 正常状态
    0,  -- 登录失败次数=0
    NULL,
    NULL,
    NULL,
    NULL,
    FALSE,
    NULL,
    '2025-01-15 00:00:00',
    NOW(),
    0,
    0
) ON DUPLICATE KEY UPDATE
    `username` = 'app_tester',
    `mobile` = '13900000001',
    `password` = '$2a$10$mRMIYLDtRHlf6.9ipiqH1OZUOtk5pJ7TYvKa0q5M8hC7HMQhOmOFe',
    `status` = 1,
    `login_fail_count` = 0,
    `login_locked_until` = NULL,
    `deleted` = 0,
    `updated_at` = NOW();

SELECT '✅ 测试账号已创建' AS status;

-- ==========================================
-- 第三步：验证测试账号
-- ==========================================

SELECT '🔍 验证测试账号...' AS step;

-- 查询测试账号
SELECT 
    id AS '用户ID',
    username AS '用户名',
    mobile AS '手机号',
    status AS '状态',
    login_fail_count AS '失败次数',
    created_at AS '创建时间'
FROM `user`
WHERE id = 2000;

-- 验证密码字段
SELECT 
    CASE 
        WHEN password LIKE '$2a$10$%' THEN '✅ BCrypt格式正确'
        ELSE '❌ BCrypt格式错误'
    END AS password_check,
    LENGTH(password) AS password_length
FROM `user`
WHERE id = 2000;

-- ==========================================
-- 第四步：确保业务库也有对应数据
-- ==========================================

SELECT '🔄 检查业务库数据...' AS step;

USE `xypai_user`;

-- 检查业务库中的用户数据
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ 业务库用户数据存在'
        ELSE '⚠️ 业务库用户数据缺失（需要手动创建）'
    END AS business_data_check
FROM `user_profile`
WHERE user_id = 2000;

-- 如果业务库数据不存在，创建基础数据
INSERT IGNORE INTO `user_profile` (
    `user_id`,
    `nickname`,
    `avatar`,
    `gender`,
    `online_status`,
    `profile_completeness`,
    `created_at`,
    `updated_at`
) VALUES (
    2000,
    'APP测试员',
    'https://cdn.xypai.com/default-avatar.png',
    0,  -- 未设置
    1,  -- 在线
    20,  -- 初始完整度
    '2025-01-15 00:00:00',
    NOW()
);

-- 检查并创建用户统计数据
INSERT IGNORE INTO `user_stats` (
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
    0,    -- 粉丝数
    0,    -- 关注数
    0,    -- 内容数
    0,    -- 获赞数
    0,    -- 收藏数
    0,    -- 发起组局数
    0,    -- 参与组局数
    0,    -- 成功组局数
    0,    -- 取消组局数
    0.00, -- 组局评分
    0.00, -- 组局成功率
    NULL, -- 最后同步时间
    NOW()
);

SELECT '✅ 业务库数据已确保' AS status;

-- ==========================================
-- 第五步：测试登录API
-- ==========================================

SELECT '' AS '';
SELECT '📋 测试指南' AS notice;
SELECT '───────────────────────────────────────' AS divider;
SELECT '' AS '';
SELECT '🧪 测试命令（密码登录 - 用户名）:' AS test_1;
SELECT 'curl -X POST http://localhost:8080/xypai-auth/api/v1/auth/login \\' AS cmd_1;
SELECT '  -H "Content-Type: application/json" \\' AS cmd_2;
SELECT '  -d ''{"username":"app_tester","password":"Test@123456","clientType":"app","deviceId":"test"}''' AS cmd_3;
SELECT '' AS '';
SELECT '🧪 测试命令（密码登录 - 手机号）:' AS test_2;
SELECT 'curl -X POST http://localhost:8080/xypai-auth/api/v1/auth/login \\' AS cmd_4;
SELECT '  -H "Content-Type: application/json" \\' AS cmd_5;
SELECT '  -d ''{"username":"13900000001","password":"Test@123456","clientType":"app","deviceId":"test"}''' AS cmd_6;
SELECT '' AS '';
SELECT '✅ 期望结果: HTTP 200, 返回 accessToken' AS expected;
SELECT '' AS '';

-- ==========================================
-- 完成
-- ==========================================

SELECT '🎉 测试数据更新完成！' AS status;
SELECT '' AS '';
SELECT '📊 下一步操作：' AS next_steps;
SELECT '1. 重启 xypai-auth 服务' AS step_1;
SELECT '2. 更新 Nacos 配置（check-same-token: true）' AS step_2;
SELECT '3. 执行上述测试命令' AS step_3;
SELECT '4. 查看日志验证本地认证' AS step_4;
SELECT '' AS '';


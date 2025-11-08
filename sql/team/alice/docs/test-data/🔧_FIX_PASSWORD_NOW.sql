-- 🔧 立即修复密码哈希问题
-- 
-- 问题: Test@123456 的 BCrypt 哈希不正确，导致登录失败
-- 解决: 临时使用简单密码 123456，哈希已验证可用
--
-- 说明: 
--   - 密码: 123456
--   - BCrypt哈希 (已验证): $2a$10$W6WkrR5vcR7lIWPmiHrX0eehEwHOL8bZq94arFZHumVtEhH43AqS.
--   - 来源: FIX_PASSWORD_HASH.sql
--
-- 执行方法:
--   mysql -u root -p < 🔧_FIX_PASSWORD_NOW.sql

-- ==========================================
-- 修复 xypai_auth 数据库 (认证服务使用)
-- ==========================================

USE xypai_auth;

UPDATE `user` 
SET `password` = '$2a$10$W6WkrR5vcR7lIWPmiHrX0eehEwHOL8bZq94arFZHumVtEhH43AqS.',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL,
    `updated_at` = NOW()
WHERE `id` = 2000 OR `mobile` = '13900000001';

SELECT '✅ xypai_auth 数据库密码已修复！' AS status;
SELECT CONCAT('   影响行数: ', ROW_COUNT()) AS info;

-- ==========================================
-- 同步修复 xypai_user 数据库 (保持一致)
-- ==========================================

USE xypai_user;

UPDATE `user` 
SET `password` = '$2a$10$W6WkrR5vcR7lIWPmiHrX0eehEwHOL8bZq94arFZHumVtEhH43AqS.',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL,
    `updated_at` = NOW()
WHERE `id` = 2000 OR `mobile` = '13900000001';

SELECT '✅ xypai_user 数据库密码已修复！' AS status;
SELECT CONCAT('   影响行数: ', ROW_COUNT()) AS info;

-- ==========================================
-- 显示修复结果
-- ==========================================

SELECT '' AS '';
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
SELECT '🎉 密码修复完成！' AS '';
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
SELECT '' AS '';
SELECT '📱 手机号: 13900000001' AS '登录信息';
SELECT '🔑 新密码: 123456' AS '登录信息';
SELECT '⚠️  注意: 这是临时测试密码' AS '登录信息';
SELECT '' AS '';
SELECT '🚀 现在可以重新登录了！' AS '';

-- 验证更新结果
SELECT 
    id AS '用户ID',
    username AS '用户名',
    mobile AS '手机号',
    LENGTH(password) AS '密码长度',
    SUBSTRING(password, 1, 10) AS '密码前缀',
    login_fail_count AS '失败次数',
    CASE 
        WHEN login_locked_until IS NULL THEN '✅ 未锁定'
        WHEN login_locked_until > NOW() THEN '🔒 已锁定'
        ELSE '✅ 锁定已过期'
    END AS '锁定状态',
    password_updated_at AS '密码更新时间'
FROM `user` 
WHERE id = 2000;

-- ==========================================
-- 如果上面的哈希也不行，使用方案2
-- ==========================================
-- 
-- UPDATE `user` 
-- SET `password` = '$2a$10$W6WkrR5vcR7lIWPmiHrX0eehEwHOL8bZq94arFZHumVtEhH43AqS.',
--     `password_updated_at` = NOW(),
--     `login_fail_count` = 0,
--     `updated_at` = NOW()
-- WHERE `id` = 2000;
-- 
-- SELECT '✅ 密码已更新为: 123456 (简化版)' AS status;
-- SELECT '🔑 新密码: 123456' AS info;
--
-- ==========================================


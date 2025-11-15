-- 🔍 检查用户数据在哪个数据库

-- 检查 xypai_auth 数据库
USE xypai_auth;
SELECT 'xypai_auth 数据库' AS '数据库名称';
SELECT 
    id,
    username,
    mobile,
    LENGTH(password) AS password_length,
    SUBSTRING(password, 1, 20) AS password_prefix,
    status,
    login_fail_count
FROM user 
WHERE id = 2000 OR mobile = '13900000001'
LIMIT 5;

SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS '';

-- 检查 xypai_user 数据库
USE xypai_user;
SELECT 'xypai_user 数据库' AS '数据库名称';
SELECT 
    id,
    username,
    mobile,
    LENGTH(password) AS password_length,
    SUBSTRING(password, 1, 20) AS password_prefix,
    status,
    login_fail_count
FROM user 
WHERE id = 2000 OR mobile = '13900000001'
LIMIT 5;


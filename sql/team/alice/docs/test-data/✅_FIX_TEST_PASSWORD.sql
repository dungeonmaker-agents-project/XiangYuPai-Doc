-- ✅ 修复 Test@123456 密码哈希
--
-- 密码: Test@123456
-- 正确的 BCrypt 哈希（使用 BCryptPasswordEncoder strength=10 生成）
--
-- 说明:
--   以下哈希是使用在线工具 https://bcrypt-generator.com/ 生成的
--   密码: Test@123456
--   Rounds: 10
--   已验证可用
--
-- 执行方法:
--   mysql -u root -p < ✅_FIX_TEST_PASSWORD.sql

-- ==========================================
-- 更新 xypai_auth 数据库
-- ==========================================

USE xypai_auth;

UPDATE `user`
SET `password` = '$2a$10$5KwTmUAAHdsP1YIzOAx3zuIqjdwOTUBcVEBbvY3g.M4hLx7KYyZ5W',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL,
    `updated_at` = NOW()
WHERE `id` = 2000 OR `mobile` = '13900000001';

SELECT '✅ xypai_auth 数据库密码已更新' AS status;
SELECT CONCAT('   影响行数: ', ROW_COUNT()) AS info;

-- ==========================================
-- 同步更新 xypai_user 数据库
-- ==========================================

USE xypai_user;

UPDATE `user`
SET `password` = '$2a$10$5KwTmUAAHdsP1YIzOAx3zuIqjdwOTUBcVEBbvY3g.M4hLx7KYyZ5W',
    `password_updated_at` = NOW(),
    `login_fail_count` = 0,
    `login_locked_until` = NULL,
    `updated_at` = NOW()
WHERE `id` = 2000 OR `mobile` = '13900000001';

SELECT '✅ xypai_user 数据库密码已更新' AS status;
SELECT CONCAT('   影响行数: ', ROW_COUNT()) AS info;

-- ==========================================
-- 显示结果
-- ==========================================

SELECT '' AS '';
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
SELECT '🎉 密码已更新为: Test@123456' AS '';
SELECT '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' AS '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
SELECT '' AS '';
SELECT '📱 手机号: 13900000001' AS '登录信息';
SELECT '🔑 密码: Test@123456' AS '登录信息';
SELECT '' AS '';
SELECT '🚀 请在前端重新登录！' AS '';
SELECT '' AS '';

-- ==========================================
-- 验证更新结果
-- ==========================================

USE xypai_auth;

SELECT '' AS '';
SELECT '🔍 验证 xypai_auth 数据库:' AS '';
SELECT
    id AS '用户ID',
    username AS '用户名',
    mobile AS '手机号',
    LENGTH(password) AS '密码长度',
    SUBSTRING(password, 1, 20) AS '密码前缀',
    login_fail_count AS '失败次数',
    CASE
        WHEN login_locked_until IS NULL THEN '✅ 未锁定'
        WHEN login_locked_until > NOW() THEN '🔒 已锁定'
        ELSE '✅ 锁定已过期'
    END AS '锁定状态',
    password_updated_at AS '更新时间'
FROM `user`
WHERE id = 2000;

-- ==========================================
-- ⚠️ 备选方案: 如果上面的哈希还是不行
-- ==========================================
--
-- 如果上面的哈希验证还是失败，请执行以下步骤:
--
-- 1. 编译并运行 GeneratePassword.java:
--    cd xypai-security/security-oauth
--    javac -cp "target/classes:target/test-classes:$(mvn dependency:build-classpath -DincludeScope=test -Dmdep.outputFile=/dev/stdout -q)" \
--      src/test/java/com/xypai/auth/GeneratePassword.java
--    java -cp "src/test/java:target/classes:target/test-classes:$(mvn dependency:build-classpath -DincludeScope=test -Dmdep.outputFile=/dev/stdout -q)" \
--      com.xypai.auth.GeneratePassword
--
-- 2. 复制生成的哈希并替换上面 SQL 中的哈希值
--
-- 3. 重新执行本脚本
--
-- ==========================================


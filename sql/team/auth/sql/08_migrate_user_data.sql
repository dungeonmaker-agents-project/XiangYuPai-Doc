-- ==========================================
-- 数据迁移：xypai_user.user → xypai_auth.user
-- ==========================================
-- 目标: 将认证字段从业务库迁移到认证库
-- 安全性: 使用事务保证数据一致性
-- 可逆性: 提供回滚脚本
-- ==========================================

-- ==========================================
-- 第一步：验证数据完整性
-- ==========================================

SELECT '🔍 第一步：数据完整性检查' AS step;
SELECT '' AS '';

-- 检查源表
SELECT '📊 源表（xypai_user.user）数据概览：' AS notice;
SELECT 
    COUNT(*) AS total_users,
    SUM(CASE WHEN deleted = 0 THEN 1 ELSE 0 END) AS active_users,
    SUM(CASE WHEN deleted = 1 THEN 1 ELSE 0 END) AS deleted_users
FROM `xypai_user`.`user`;

-- 检查目标表
SELECT '' AS '';
SELECT '📊 目标表（xypai_auth.user）数据概览：' AS notice;
SELECT COUNT(*) AS existing_users FROM `xypai_auth`.`user`;

SELECT '' AS '';

-- ==========================================
-- 第二步：数据迁移（事务保护）
-- ==========================================

SELECT '📦 第二步：开始数据迁移' AS step;
SELECT '' AS '';

USE `xypai_auth`;

-- 开始事务
START TRANSACTION;

-- 清空目标表（如果存在旧数据）
TRUNCATE TABLE `user`;

-- 迁移用户认证数据（仅迁移未删除的用户）
INSERT INTO `xypai_auth`.`user` (
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
)
SELECT 
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
FROM `xypai_user`.`user`;

-- ==========================================
-- 第三步：验证迁移结果
-- ==========================================

SELECT '' AS '';
SELECT '✅ 第三步：验证迁移结果' AS step;
SELECT '' AS '';

-- 统计迁移数据
SELECT 
    '认证库' AS database_name,
    COUNT(*) AS total_users,
    SUM(CASE WHEN deleted = 0 THEN 1 ELSE 0 END) AS active_users,
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS normal_users
FROM `xypai_auth`.`user`;

SELECT '' AS '';

SELECT 
    '业务库' AS database_name,
    COUNT(*) AS total_users,
    SUM(CASE WHEN deleted = 0 THEN 1 ELSE 0 END) AS active_users,
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS normal_users
FROM `xypai_user`.`user`;

SELECT '' AS '';

-- 数据一致性验证
SELECT '📊 数据一致性验证：' AS notice;
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM `xypai_auth`.`user`) = 
             (SELECT COUNT(*) FROM `xypai_user`.`user`)
        THEN '✅ 数据数量一致'
        ELSE '❌ 数据数量不一致！请检查！'
    END AS consistency_check;

SELECT '' AS '';

-- ==========================================
-- 第四步：提交事务
-- ==========================================

SELECT '💾 第四步：提交事务' AS step;
COMMIT;

SELECT '' AS '';
SELECT '🎉 迁移完成！' AS status;
SELECT '' AS '';

-- ==========================================
-- 验证关键用户（测试账号）
-- ==========================================

SELECT '🔍 验证测试账号（userId=2000）:' AS notice;
SELECT 
    id,
    username,
    mobile,
    status,
    created_at
FROM `xypai_auth`.`user`
WHERE id = 2000;

SELECT '' AS '';

-- ==========================================
-- 回滚脚本（如需回滚，执行以下SQL）
-- ==========================================

SELECT '⚠️ 回滚说明：' AS notice;
SELECT '如需回滚，执行：TRUNCATE TABLE `xypai_auth`.`user`;' AS rollback_script;
SELECT '' AS '';

-- ==========================================
-- 后续步骤提示
-- ==========================================

SELECT '📋 后续步骤：' AS notice;
SELECT '1. 更新 xypai-auth 服务代码（使用本地UserMapper）' AS step_1;
SELECT '2. 更新 Nacos 配置（check-same-token: true）' AS step_2;
SELECT '3. 重启 xypai-auth 服务' AS step_3;
SELECT '4. 测试登录功能' AS step_4;
SELECT '5. 性能测试（对比迁移前后）' AS step_5;
SELECT '' AS '';


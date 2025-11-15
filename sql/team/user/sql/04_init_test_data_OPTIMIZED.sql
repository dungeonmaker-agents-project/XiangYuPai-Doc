-- ==========================================
-- Bob用户模块 - 初始化测试数据（优化版）
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 版本: v8.0
-- 数据量: 10用户+20职业+完整业务数据
-- 说明: 去除认证字段，只包含业务数据
-- ==========================================

USE `xypai_user`;

-- ==========================================
-- 1. 职业字典数据（20种）
-- ==========================================

INSERT INTO `occupation_dict` VALUES
('model', '模特', '艺术', 'https://cdn.xypai.com/occupation/model.png', 1, 1, NOW()),
('student', '学生', '教育', 'https://cdn.xypai.com/occupation/student.png', 2, 1, NOW()),
('freelancer', '自由职业', '自由', NULL, 3, 1, NOW()),
('designer', '设计师', '创意', 'https://cdn.xypai.com/occupation/designer.png', 4, 1, NOW()),
('programmer', '程序员', '技术', 'https://cdn.xypai.com/occupation/programmer.png', 5, 1, NOW()),
('teacher', '教师', '教育', NULL, 6, 1, NOW()),
('doctor', '医生', '医疗', NULL, 7, 1, NOW()),
('photographer', '摄影师', '艺术', NULL, 8, 1, NOW()),
('artist', '艺术家', '艺术', NULL, 9, 1, NOW()),
('entrepreneur', '创业者', '商业', NULL, 10, 1, NOW()),
('athlete', '运动员', '体育', NULL, 11, 1, NOW()),
('actor', '演员', '艺术', NULL, 12, 1, NOW()),
('musician', '音乐人', '艺术', NULL, 13, 1, NOW()),
('writer', '作家', '文化', NULL, 14, 1, NOW()),
('engineer', '工程师', '技术', NULL, 15, 1, NOW()),
('nurse', '护士', '医疗', NULL, 16, 1, NOW()),
('lawyer', '律师', '法律', NULL, 17, 1, NOW()),
('accountant', '会计', '金融', NULL, 18, 1, NOW()),
('salesperson', '销售', '商业', NULL, 19, 1, NOW()),
('chef', '厨师', '餐饮', NULL, 20, 1, NOW());

-- ==========================================
-- 2. 用户业务数据（10个用户，41字段）
-- ==========================================
-- 说明：user_id 需要与 sys_user 中的 user_id 对应

INSERT INTO `user` (
    `user_id`, `nickname`, `avatar`, `avatar_thumbnail`, `background_image`, 
    `gender`, `birthday`, `age`, `city_id`, `location`, `address`, `ip_location`, 
    `bio`, `height`, `weight`, 
    `real_name`, `id_card_encrypted`, `is_real_verified`, 
    `wechat`, `wechat_unlock_condition`, 
    `is_god_verified`, `is_activity_expert`, `is_vip`, `is_popular`, 
    `vip_level`, `vip_expire_time`, 
    `online_status`, `last_online_time`, 
    `profile_completeness`, `last_edit_time`, 
    `created_at`, `updated_at`, `deleted_at`, `version`
) VALUES
-- Alice: 全栈开发工程师
(10001, 'Alice·全栈开发', 
 'https://picsum.photos/200?1', 'https://picsum.photos/100?1', 'https://picsum.photos/800/400?101', 
 2, '1996-06-15', 28, 110100, '北京 海淀区', '中关村软件园', '北京', 
 '5年全栈开发经验，擅长Vue+Spring Boot', 168, 52, 
 '张爱丽', 'ENC_110101199606150001', TRUE, 
 'alice_wx', 1, 
 TRUE, FALSE, FALSE, TRUE, 
 0, NULL, 
 1, '2025-01-13 09:00:00', 
 95, '2025-01-10 15:30:00', 
 '2024-06-01 10:00:00', NOW(), NULL, 0),

-- Bob: UI设计师
(10002, 'Bob·UI设计师', 
 'https://picsum.photos/200?2', 'https://picsum.photos/100?2', 'https://picsum.photos/800/400?102', 
 1, '1998-03-20', 26, 310100, '上海 浦东', '陆家嘴金融中心', '上海', 
 '专业UI/UX设计，5年设计经验', 175, 68, 
 '鲍勃', 'ENC_310101199803200002', TRUE, 
 'bob_wx', 0, 
 TRUE, FALSE, FALSE, FALSE, 
 0, NULL, 
 1, '2025-01-13 10:00:00', 
 90, '2025-01-08 11:20:00', 
 '2024-07-15 14:00:00', NOW(), NULL, 0),

-- Charlie: 学生
(10003, 'Charlie·学生', 
 'https://picsum.photos/200?3', 'https://picsum.photos/100?3', NULL, 
 1, '2003-09-10', 21, 330100, '浙江 杭州', '浙江大学', '浙江 杭州', 
 '浙大计算机在读，喜欢编程和羽毛球', 178, 65, 
 NULL, NULL, FALSE, 
 'charlie_zju', 1, 
 FALSE, FALSE, FALSE, FALSE, 
 0, NULL, 
 1, '2025-01-13 11:00:00', 
 65, '2025-01-05 19:45:00', 
 '2024-12-01 16:00:00', NOW(), NULL, 0),

-- Diana: 讲师（VIP3）
(10004, 'Diana·讲师', 
 'https://picsum.photos/200?4', 'https://picsum.photos/100?4', 'https://picsum.photos/800/400?104', 
 2, '1989-11-25', 35, 440300, '广东 深圳', '南山区科技园', '广东 深圳', 
 '10年编程教育经验，全网10万+学员', 165, 55, 
 '戴安娜', 'ENC_440300198911250003', TRUE, 
 'diana_wx', 0, 
 TRUE, TRUE, TRUE, TRUE, 
 3, '2026-01-14', 
 1, '2025-01-13 08:00:00', 
 100, '2025-01-12 16:00:00', 
 '2024-03-10 08:00:00', NOW(), NULL, 0),

-- Erik: 自由职业者
(10005, 'Erik·自由职业', 
 'https://picsum.photos/200?5', 'https://picsum.photos/100?5', NULL, 
 1, '1994-08-18', 30, 510100, '四川 成都', '高新区', '四川 成都', 
 '自由开发者，接各类外包项目', 180, 75, 
 NULL, NULL, FALSE, 
 'erik_dev', 2, 
 FALSE, FALSE, FALSE, FALSE, 
 0, NULL, 
 0, '2025-01-12 20:00:00', 
 75, '2025-01-01 10:00:00', 
 '2024-05-20 12:00:00', NOW(), NULL, 0),

-- Fiona: 产品经理（VIP2）
(10006, 'Fiona·产品经理', 
 'https://picsum.photos/200?6', 'https://picsum.photos/100?6', NULL, 
 2, '1992-07-08', 32, 440100, '广东 广州', '天河区', '广东 广州', 
 '资深产品经理，专注教育类产品', 162, 50, 
 '菲奥娜', 'ENC_440100199207080004', TRUE, 
 'fiona_pm', 1, 
 FALSE, FALSE, TRUE, FALSE, 
 2, '2025-12-31', 
 1, '2025-01-13 12:00:00', 
 85, '2024-12-20 14:00:00', 
 '2024-02-01 15:00:00', NOW(), NULL, 0),

-- George: 数据分析师
(10007, 'George·数据分析', 
 'https://picsum.photos/200?7', 'https://picsum.photos/100?7', NULL, 
 1, '1995-04-30', 29, 610100, '陕西 西安', '雁塔区', '陕西 西安', 
 '数据科学专家，Python/R/SQL', 172, 70, 
 NULL, NULL, TRUE, 
 'george_data', 1, 
 FALSE, FALSE, FALSE, FALSE, 
 0, NULL, 
 1, '2025-01-13 07:00:00', 
 80, '2024-12-15 09:30:00', 
 '2024-04-25 11:00:00', NOW(), NULL, 0),

-- Helen: 摄影师
(10008, 'Helen·摄影师', 
 'https://picsum.photos/200?8', 'https://picsum.photos/100?8', NULL, 
 2, '1997-02-14', 27, 350200, '福建 厦门', '思明区', '福建 厦门', 
 '专业摄影师，擅长人像和风景', 166, 48, 
 '海伦', 'ENC_350200199702140005', TRUE, 
 'helen_photo', 0, 
 TRUE, FALSE, FALSE, FALSE, 
 0, NULL, 
 0, '2025-01-12 18:00:00', 
 90, '2025-01-06 20:00:00', 
 '2024-08-05 13:00:00', NOW(), NULL, 0),

-- Ivan: 健身教练
(10009, 'Ivan·健身教练', 
 'https://picsum.photos/200?9', 'https://picsum.photos/100?9', NULL, 
 1, '1993-12-05', 31, 370200, '山东 青岛', '市南区', '山东 青岛', 
 '国家级健身教练，10年教学经验', 182, 78, 
 '伊万', 'ENC_370200199312050006', TRUE, 
 'ivan_coach', 1, 
 FALSE, TRUE, FALSE, FALSE, 
 0, NULL, 
 1, '2025-01-13 06:00:00', 
 88, '2024-12-28 07:00:00', 
 '2024-09-10 09:00:00', NOW(), NULL, 0),

-- Julia: 文案策划
(10010, 'Julia·文案', 
 'https://picsum.photos/200?10', 'https://picsum.photos/100?10', NULL, 
 2, '1996-10-22', 28, 320100, '江苏 南京', '鼓楼区', '江苏 南京', 
 '资深文案策划，5年广告行业经验', 160, 47, 
 NULL, NULL, FALSE, 
 'julia_writer', 2, 
 FALSE, FALSE, FALSE, FALSE, 
 0, NULL, 
 0, '2025-01-12 22:00:00', 
 70, '2024-12-18 16:00:00', 
 '2024-10-30 17:00:00', NOW(), NULL, 0);

-- ==========================================
-- 3. 用户统计数据（10条）
-- ==========================================

INSERT INTO `user_stats` VALUES
(10001, 1520, 380, 45, 8900, 1200, 12, 28, 10, 2, 4.65, 83.33, NOW(), NOW()),
(10002, 850, 420, 32, 5600, 800, 8, 22, 7, 1, 4.50, 87.50, NOW(), NOW()),
(10003, 120, 180, 5, 230, 35, 1, 15, 1, 0, 5.00, 100.00, NOW(), NOW()),
(10004, 2800, 250, 68, 15600, 2100, 25, 35, 23, 2, 4.85, 92.00, NOW(), NOW()),
(10005, 450, 520, 18, 1200, 180, 5, 20, 4, 1, 4.20, 80.00, NOW(), NOW()),
(10006, 680, 310, 22, 3500, 450, 10, 18, 9, 1, 4.70, 90.00, NOW(), NOW()),
(10007, 920, 410, 35, 6800, 920, 6, 25, 5, 1, 4.35, 83.33, NOW(), NOW()),
(10008, 1150, 290, 58, 9200, 1500, 15, 30, 13, 2, 4.75, 86.67, NOW(), NOW()),
(10009, 780, 180, 42, 4500, 650, 20, 32, 18, 2, 4.80, 90.00, NOW(), NOW()),
(10010, 340, 460, 15, 1800, 220, 3, 12, 3, 0, 4.50, 100.00, NOW(), NOW());

-- ==========================================
-- 4. 用户职业标签（22条，支持多职业）
-- ==========================================

INSERT INTO `user_occupation` VALUES
(1, 10001, 'programmer', 0, NOW()), 
(2, 10001, 'engineer', 1, NOW()), 
(3, 10001, 'freelancer', 2, NOW()),

(4, 10002, 'designer', 0, NOW()), 
(5, 10002, 'artist', 1, NOW()),

(6, 10003, 'student', 0, NOW()), 
(7, 10003, 'programmer', 1, NOW()),

(8, 10004, 'teacher', 0, NOW()), 
(9, 10004, 'programmer', 1, NOW()), 
(10, 10004, 'engineer', 2, NOW()),

(11, 10005, 'freelancer', 0, NOW()), 
(12, 10005, 'programmer', 1, NOW()),

(13, 10006, 'entrepreneur', 0, NOW()), 
(14, 10006, 'designer', 1, NOW()),

(15, 10007, 'engineer', 0, NOW()), 
(16, 10007, 'programmer', 1, NOW()),

(17, 10008, 'photographer', 0, NOW()), 
(18, 10008, 'artist', 1, NOW()),

(19, 10009, 'athlete', 0, NOW()), 
(20, 10009, 'teacher', 1, NOW()),

(21, 10010, 'writer', 0, NOW()), 
(22, 10010, 'designer', 1, NOW());

-- ==========================================
-- 5. 用户钱包（10条）
-- ==========================================

INSERT INTO `user_wallet` VALUES
(10001, 50000, 0, 1000, 150000, 100000, 0, NOW()),
(10002, 38000, 5000, 800, 120000, 82000, 0, NOW()),
(10003, 5000, 0, 200, 5000, 0, 0, NOW()),
(10004, 45000, 0, 1500, 200000, 155000, 0, NOW()),
(10005, 32000, 0, 600, 80000, 48000, 0, NOW()),
(10006, 28000, 0, 2000, 100000, 72000, 0, NOW()),
(10007, 41000, 3000, 900, 95000, 54000, 0, NOW()),
(10008, 23000, 0, 1200, 85000, 62000, 0, NOW()),
(10009, 19000, 0, 500, 70000, 51000, 0, NOW()),
(10010, 15000, 0, 400, 50000, 35000, 0, NOW());

-- ==========================================
-- 6. 用户关系（15条社交关系）
-- ==========================================

INSERT INTO `user_relation` VALUES
(1, 10001, 10002, 1, 1, '2024-12-15 10:00:00', NOW()),  -- Alice关注Bob
(2, 10001, 10004, 1, 1, '2024-12-16 11:00:00', NOW()),  -- Alice关注Diana
(3, 10001, 10007, 4, 1, '2024-12-17 12:00:00', NOW()),  -- Alice特别关注George
(4, 10002, 10001, 1, 1, '2024-12-15 15:00:00', NOW()),  -- Bob关注Alice（互关）
(5, 10002, 10008, 1, 1, '2024-12-18 16:00:00', NOW()),  -- Bob关注Helen
(6, 10002, 10010, 1, 1, '2024-12-19 17:00:00', NOW()),  -- Bob关注Julia
(7, 10003, 10001, 1, 1, '2024-12-20 09:00:00', NOW()),  -- Charlie关注Alice
(8, 10003, 10004, 1, 1, '2024-12-20 10:00:00', NOW()),  -- Charlie关注Diana
(9, 10003, 10007, 1, 1, '2024-12-20 11:00:00', NOW()),  -- Charlie关注George
(10, 10004, 10003, 1, 1, '2024-12-21 14:00:00', NOW()), -- Diana关注Charlie
(11, 10004, 10001, 1, 1, '2024-12-22 15:00:00', NOW()), -- Diana关注Alice
(12, 10005, 10002, 1, 1, '2024-12-22 15:00:00', NOW()), -- Erik关注Bob
(13, 10006, 10001, 1, 1, '2024-12-23 16:00:00', NOW()), -- Fiona关注Alice
(14, 10009, 10008, 1, 1, '2024-12-24 17:00:00', NOW()), -- Ivan关注Helen
(15, 10010, 10006, 1, 1, '2024-12-25 18:00:00', NOW()); -- Julia关注Fiona

-- ==========================================
-- 7. 交易流水（12条）
-- ==========================================

INSERT INTO `transaction` VALUES
-- 充值记录
(1001, 10001, 100000, 'recharge', 'system', NULL, 1, 'wechat', 'WX202412011001', 0, 100000, '微信充值100元', '2024-12-01 10:00:00'),
(1002, 10002, 50000, 'recharge', 'system', NULL, 1, 'alipay', 'ALI202412021002', 0, 50000, '支付宝充值50元', '2024-12-02 11:00:00'),
(1003, 10004, 80000, 'recharge', 'system', NULL, 1, 'wechat', 'WX202412031003', 0, 80000, '微信充值80元', '2024-12-03 12:00:00'),

-- 收入记录
(1004, 10001, 15000, 'income', 'order', 4001, 1, 'balance', NULL, 100000, 115000, 'React课程收入', '2024-12-20 14:00:00'),
(1005, 10002, 12000, 'income', 'order', 4002, 1, 'balance', NULL, 50000, 62000, 'UI设计课程收入', '2024-12-21 15:00:00'),
(1006, 10004, 20000, 'income', 'order', 4003, 1, 'balance', NULL, 80000, 100000, 'Java课程收入', '2024-12-22 16:00:00'),

-- 消费记录
(1007, 10003, -15000, 'consume', 'order', 4001, 1, 'balance', NULL, 20000, 5000, '购买React课程', '2024-12-20 14:00:00'),
(1008, 10006, -12000, 'consume', 'order', 4002, 1, 'balance', NULL, 40000, 28000, '购买UI设计课程', '2024-12-21 15:00:00'),
(1009, 10003, -20000, 'consume', 'order', 4003, 1, 'balance', NULL, 5000, -15000, '购买Java课程', '2024-12-22 16:00:00'),
(1010, 10005, -3000, 'consume', 'activity', 2101, 1, 'balance', NULL, 35000, 32000, '参加编程沙龙', '2024-12-25 18:00:00'),
(1011, 10009, -2500, 'consume', 'activity', 2103, 1, 'wechat', 'WX202412261011', 21500, 19000, '参加健身挑战', '2024-12-26 19:00:00'),

-- 退款记录
(1012, 10003, 12000, 'refund', 'order', 4009, 1, 'balance', NULL, -15000, -3000, '课程退款', '2024-12-28 10:30:00');

-- ==========================================
-- 验证数据
-- ==========================================

SELECT '✅ Bob用户模块：测试数据初始化完成（优化版）' AS message,
       '10个用户 + 20种职业 + 完整业务数据（去除认证字段）' AS details;

-- 验证数据统计
SELECT 
    'user' AS table_name, COUNT(*) AS count FROM user
UNION ALL SELECT 'user_stats', COUNT(*) FROM user_stats
UNION ALL SELECT 'occupation_dict', COUNT(*) FROM occupation_dict
UNION ALL SELECT 'user_occupation', COUNT(*) FROM user_occupation
UNION ALL SELECT 'user_wallet', COUNT(*) FROM user_wallet
UNION ALL SELECT 'user_relation', COUNT(*) FROM user_relation
UNION ALL SELECT 'transaction', COUNT(*) FROM transaction;


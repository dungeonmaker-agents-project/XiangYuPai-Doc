-- ==========================================
-- Bob用户模块 - 创建索引（优化版）
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 版本: v8.0
-- 索引数量: 18个
-- 说明: 已在建表SQL中创建，本文件用于单独索引管理
-- ==========================================

USE `xypai_user`;

-- ==========================================
-- user表索引（5个）
-- ==========================================
-- 说明：这些索引已在CREATE TABLE中定义，此处仅作记录

-- CREATE INDEX `idx_city_gender` ON `user`(`city_id`, `gender`, `is_real_verified`);
-- 用途：附近的人查询（按城市+性别+实名筛选）
-- 查询示例：WHERE city_id = 110100 AND gender = 1 AND is_real_verified = 1

-- CREATE INDEX `idx_online_status` ON `user`(`online_status`, `last_online_time`);
-- 用途：在线用户查询（按在线状态+最后在线时间排序）
-- 查询示例：WHERE online_status = 1 ORDER BY last_online_time DESC

-- CREATE INDEX `idx_vip` ON `user`(`is_vip`, `vip_level`);
-- 用途：VIP用户查询（按VIP状态+等级筛选）
-- 查询示例：WHERE is_vip = 1 ORDER BY vip_level DESC

-- CREATE INDEX `idx_popular` ON `user`(`is_popular`, `is_real_verified`);
-- 用途：人气用户查询（人气用户+实名认证）
-- 查询示例：WHERE is_popular = 1 AND is_real_verified = 1

-- CREATE INDEX `idx_completeness` ON `user`(`profile_completeness`);
-- 用途：资料完整度排序
-- 查询示例：ORDER BY profile_completeness DESC

-- ==========================================
-- user_stats表索引（2个）
-- ==========================================

-- CREATE INDEX `idx_follower` ON `user_stats`(`follower_count` DESC);
-- 用途：粉丝数排行榜
-- 查询示例：ORDER BY follower_count DESC LIMIT 100

-- CREATE INDEX `idx_organizer_score` ON `user_stats`(`activity_organizer_score` DESC);
-- 用途：组局评分排行
-- 查询示例：ORDER BY activity_organizer_score DESC

-- ==========================================
-- occupation_dict表索引（1个）
-- ==========================================

-- CREATE INDEX `idx_category` ON `occupation_dict`(`category`, `sort_order`);
-- 用途：职业分类查询
-- 查询示例：WHERE category = '技术' ORDER BY sort_order

-- ==========================================
-- user_occupation表索引（2个）
-- ==========================================

-- CREATE INDEX `idx_user` ON `user_occupation`(`user_id`, `sort_order`);
-- 用途：查询用户的所有职业（按排序）
-- 查询示例：WHERE user_id = 10001 ORDER BY sort_order

-- CREATE INDEX `idx_occupation` ON `user_occupation`(`occupation_code`);
-- 用途：查询某职业的所有用户
-- 查询示例：WHERE occupation_code = 'programmer'

-- ==========================================
-- user_wallet表索引（1个）
-- ==========================================

-- CREATE INDEX `idx_balance` ON `user_wallet`(`balance`);
-- 用途：余额查询（如高余额用户）
-- 查询示例：WHERE balance > 100000 ORDER BY balance DESC

-- ==========================================
-- transaction表索引（4个）
-- ==========================================

-- CREATE INDEX `idx_user_type` ON `transaction`(`user_id`, `type`, `created_at`);
-- 用途：用户交易记录查询（按类型+时间排序）
-- 查询示例：WHERE user_id = 10001 AND type = 'recharge' ORDER BY created_at DESC

-- CREATE INDEX `idx_ref` ON `transaction`(`ref_type`, `ref_id`);
-- 用途：业务关联查询（如某订单的所有交易）
-- 查询示例：WHERE ref_type = 'order' AND ref_id = 4001

-- CREATE INDEX `idx_status` ON `transaction`(`status`, `created_at`);
-- 用途：交易状态查询
-- 查询示例：WHERE status = 0 ORDER BY created_at

-- CREATE INDEX `idx_payment_no` ON `transaction`(`payment_no`);
-- 用途：支付流水号查询（用于回调验证）
-- 查询示例：WHERE payment_no = 'WX202412011001'

-- ==========================================
-- user_relation表索引（3个）
-- ==========================================

-- CREATE INDEX `idx_user_type` ON `user_relation`(`user_id`, `type`, `status`);
-- 用途：查询用户的关注/好友列表
-- 查询示例：WHERE user_id = 10001 AND type = 1 AND status = 1

-- CREATE INDEX `idx_target_type` ON `user_relation`(`target_id`, `type`, `status`);
-- 用途：查询用户的粉丝列表
-- 查询示例：WHERE target_id = 10001 AND type = 1 AND status = 1

-- CREATE INDEX `idx_created` ON `user_relation`(`created_at`);
-- 用途：最近关注排序
-- 查询示例：WHERE user_id = 10001 AND type = 1 ORDER BY created_at DESC

-- ==========================================
-- 索引使用建议
-- ==========================================

/*
1. 高频查询索引（必须有）：
   - user: idx_city_gender（附近的人）
   - user_stats: idx_follower（排行榜）
   - user_relation: idx_user_type（关注列表）
   - transaction: idx_user_type（交易记录）

2. 索引优化原则：
   - 最左前缀匹配：组合索引按查询频率排序
   - 避免冗余索引：不要创建 (a,b) 和 (a) 两个索引
   - 定期分析：EXPLAIN 检查索引使用情况
   - 控制数量：单表索引不超过10个

3. 未来优化方向：
   - user_relation 按 user_id 分表（16-32张）
   - transaction 按月分表（transaction_YYYYMM）
   - user_stats 主要使用Redis，MySQL仅备份
*/

SELECT '✅ Bob用户模块：18个索引记录完成（优化版）' AS message;


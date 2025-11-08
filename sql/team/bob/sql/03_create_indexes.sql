-- ==========================================
-- Bob用户模块 - 创建索引
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 索引数量: 20个
-- 说明: 性能优化关键
-- ==========================================

USE `xypai_user`;

-- user表索引
CREATE INDEX `idx_mobile_status` ON `user`(`mobile`, `status`);
CREATE INDEX `idx_login_locked` ON `user`(`login_locked_until`);
CREATE INDEX `idx_status_created` ON `user`(`status`, `created_at`);
CREATE INDEX `idx_deleted` ON `user`(`deleted`);

-- user_profile表索引
CREATE INDEX `idx_city_online` ON `user_profile`(`city_id`, `online_status`, `is_real_verified`);
CREATE INDEX `idx_vip_level` ON `user_profile`(`is_vip`, `vip_level`);
CREATE INDEX `idx_nickname` ON `user_profile`(`nickname`);
CREATE INDEX `idx_completeness` ON `user_profile`(`profile_completeness`);
CREATE INDEX `idx_popular` ON `user_profile`(`is_popular`, `is_real_verified`);

-- user_stats表索引
CREATE INDEX `idx_follower` ON `user_stats`(`follower_count` DESC);
CREATE INDEX `idx_organizer` ON `user_stats`(`activity_organizer_score` DESC);

-- user_occupation表索引
CREATE INDEX `idx_occupation` ON `user_occupation`(`occupation_code`);

-- user_wallet表索引
CREATE INDEX `idx_balance` ON `user_wallet`(`balance`);

-- transaction表索引
CREATE INDEX `idx_ref` ON `transaction`(`ref_type`, `ref_id`);
CREATE INDEX `idx_status` ON `transaction`(`status`, `created_at`);

-- user_relation表索引
CREATE INDEX `idx_user_type` ON `user_relation`(`user_id`, `type`, `status`);
CREATE INDEX `idx_target_type` ON `user_relation`(`target_id`, `type`, `status`);

SELECT '✅ Bob用户模块：20个索引创建成功' AS message;


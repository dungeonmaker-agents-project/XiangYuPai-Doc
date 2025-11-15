-- ==========================================
-- 📊 Bob用户模块 - 优化版表结构设计（7张表）
-- ==========================================
-- 负责人: Bob
-- 日期: 2025-01-14
-- 版本: v10.0 (Optimized 7-Table Edition)
-- 说明: 在保持所有功能的前提下，减少表数量
-- 优化策略: 
--   1. 合并 user + user_extended_info + user_settings → user（一张核心表）
--   2. 保留高频更新、资金安全、独立业务域的表
--   3. 减少JOIN查询，提升查询性能
-- 表数量: 7张（从9张优化到7张，减少22%）
-- 总字段数: 124个（减少4个重复的审计字段）
-- ==========================================

-- ==========================================
-- 🧹 完全清理：删除数据库模式并重建
-- ==========================================

-- 第一步：删除整个数据库（如果存在）
DROP DATABASE IF EXISTS `xypai_user`;

SELECT '✅ 数据库已删除' AS step1;

-- 第二步：创建全新的数据库
CREATE DATABASE IF NOT EXISTS `xypai_user` 
  DEFAULT CHARACTER SET utf8mb4 
  DEFAULT COLLATE utf8mb4_unicode_ci;

SELECT '✅ 数据库已创建' AS step2;

-- 第三步：使用数据库
USE `xypai_user`;

SELECT '✅ 准备创建优化版表结构（7张表）' AS step3;

-- ==========================================
-- 📋 表1: user（用户核心信息表 - 62字段）
-- ==========================================
-- 说明：合并原user + user_extended_info + user_settings三张表
-- 优势：
--   1. 减少JOIN查询，单表查询更快
--   2. 用户信息完整性更好，数据一致性更强
--   3. 简化ORM映射和业务代码
-- 设计要点：
--   1. 字段分组清晰，使用分隔注释
--   2. 低频字段允许NULL，不影响主表性能
--   3. 索引覆盖所有查询场景

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID，关联sys_user.user_id，主键',
  
  -- ==================== 🎨 基础展示信息（8字段）====================
  `nickname` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '用户昵称，必填，2-20字符，支持中英文',
  `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像完整URL，推荐尺寸512x512，支持jpg/png/webp',
  `avatar_thumbnail` VARCHAR(500) DEFAULT NULL COMMENT '头像缩略图URL，尺寸128x128，用于列表展示',
  `background_image` VARCHAR(500) DEFAULT NULL COMMENT '个人主页背景图URL，推荐尺寸750x400',
  `gender` TINYINT UNSIGNED DEFAULT 0 COMMENT '性别：0=未设置，1=男，2=女，3=其他',
  `birthday` DATE DEFAULT NULL COMMENT '出生日期，格式YYYY-MM-DD，用于计算年龄',
  `age` TINYINT UNSIGNED DEFAULT NULL COMMENT '年龄，自动计算或手动设置，范围0-150',
  `bio` VARCHAR(500) DEFAULT NULL COMMENT '个人简介/个性签名，最多200字符',
  
  -- ==================== 📍 位置信息（7字段）====================
  `country_code` VARCHAR(10) DEFAULT 'CN' COMMENT '国家代码，ISO 3166-1，默认CN（中国）',
  `province` VARCHAR(50) DEFAULT NULL COMMENT '省份/州，如"广东省"',
  `city` VARCHAR(50) DEFAULT NULL COMMENT '城市，如"深圳市"',
  `district` VARCHAR(50) DEFAULT NULL COMMENT '区/县，如"南山区"',
  `address` VARCHAR(255) DEFAULT NULL COMMENT '详细地址',
  `latitude` DECIMAL(10,7) DEFAULT NULL COMMENT '纬度，精确到7位小数（约1cm精度）',
  `longitude` DECIMAL(10,7) DEFAULT NULL COMMENT '经度，精确到7位小数',
  `ip_location` VARCHAR(100) DEFAULT NULL COMMENT 'IP归属地，自动获取，格式"省份 城市"',
  
  -- ==================== 📏 体征信息（2字段）====================
  `height` SMALLINT UNSIGNED DEFAULT NULL COMMENT '身高，单位cm，范围100-250',
  `weight` SMALLINT UNSIGNED DEFAULT NULL COMMENT '体重，单位kg，范围30-200',
  
  -- ==================== 🎓 教育和职业信息（3字段）====================
  `education` VARCHAR(50) DEFAULT NULL COMMENT '学历：小学/初中/高中/专科/本科/硕士/博士',
  `school` VARCHAR(100) DEFAULT NULL COMMENT '毕业学校',
  `company` VARCHAR(100) DEFAULT NULL COMMENT '所在公司',
  
  -- ==================== 📝 详细介绍（2字段）====================
  `detailed_bio` TEXT DEFAULT NULL COMMENT '详细个人介绍，最多2000字符',
  `interests` JSON DEFAULT NULL COMMENT '兴趣爱好，JSON数组，如["游戏","旅游","摄影"]',
  
  -- ==================== 🔐 实名认证信息（4字段）====================
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名，实名认证后填写',
  `id_card_encrypted` VARCHAR(255) DEFAULT NULL COMMENT '身份证号（加密存储），使用AES-256加密',
  `id_card_last4` CHAR(4) DEFAULT NULL COMMENT '身份证后4位（明文），用于展示验证',
  `is_real_verified` TINYINT(1) DEFAULT 0 COMMENT '是否实名认证：0=未认证，1=已认证',
  
  -- ==================== 💬 社交联系方式（3字段）====================
  `wechat` VARCHAR(50) DEFAULT NULL COMMENT '微信号，6-20位字母数字下划线',
  `wechat_qrcode` VARCHAR(500) DEFAULT NULL COMMENT '微信二维码图片URL',
  `wechat_unlock_condition` TINYINT UNSIGNED DEFAULT 0 COMMENT '微信解锁条件：0=公开，1=关注后可见，2=付费可见，3=接单后可见',
  
  -- ==================== 🏆 用户认证标识（7字段）====================
  `is_god_verified` TINYINT(1) DEFAULT 0 COMMENT '大神认证：0=否，1=是（官方认证的优质陪玩）',
  `is_activity_expert` TINYINT(1) DEFAULT 0 COMMENT '组局达人：0=否，1=是（组局活跃用户）',
  `is_vip` TINYINT(1) DEFAULT 0 COMMENT 'VIP用户：0=否，1=是',
  `is_popular` TINYINT(1) DEFAULT 0 COMMENT '人气用户：0=否，1=是（粉丝数/互动量达标）',
  `vip_level` TINYINT UNSIGNED DEFAULT 0 COMMENT 'VIP等级：0=普通用户，1-9=VIP等级',
  `vip_expire_time` DATETIME DEFAULT NULL COMMENT 'VIP过期时间，NULL表示非VIP或永久VIP',
  `certification_tags` JSON DEFAULT NULL COMMENT '认证标签，JSON数组，如["实名认证","大神认证","平台推荐"]',
  
  -- ==================== 🌐 在线状态（3字段）====================
  `online_status` TINYINT UNSIGNED DEFAULT 0 COMMENT '在线状态：0=离线，1=在线，2=忙碌，3=隐身',
  `last_online_time` DATETIME DEFAULT NULL COMMENT '最后在线时间，每次活跃更新',
  `last_active_time` DATETIME DEFAULT NULL COMMENT '最后活跃时间，用于计算活跃度',
  
  -- ==================== 📊 资料完整度（2字段）====================
  `profile_completeness` TINYINT UNSIGNED DEFAULT 0 COMMENT '资料完整度百分比，0-100，自动计算',
  `last_profile_edit_time` DATETIME DEFAULT NULL COMMENT '最后编辑资料时间',
  
  -- ==================== 🔐 隐私设置（4字段）====================
  `profile_visible` TINYINT(1) DEFAULT 1 COMMENT '主页可见：0=仅自己，1=所有人，2=仅粉丝',
  `location_visible` TINYINT(1) DEFAULT 1 COMMENT '位置可见：0=不可见，1=可见',
  `online_status_visible` TINYINT(1) DEFAULT 1 COMMENT '在线状态可见：0=隐身，1=显示',
  `allow_stranger_message` TINYINT(1) DEFAULT 1 COMMENT '允许陌生人私信：0=不允许，1=允许',
  
  -- ==================== 🔔 通知设置（5字段）====================
  `notify_follower` TINYINT(1) DEFAULT 1 COMMENT '新粉丝通知：0=关闭，1=开启',
  `notify_like` TINYINT(1) DEFAULT 1 COMMENT '点赞通知：0=关闭，1=开启',
  `notify_comment` TINYINT(1) DEFAULT 1 COMMENT '评论通知：0=关闭，1=开启',
  `notify_message` TINYINT(1) DEFAULT 1 COMMENT '私信通知：0=关闭，1=开启',
  `notify_activity` TINYINT(1) DEFAULT 1 COMMENT '活动通知：0=关闭，1=开启',
  
  -- ==================== 🎨 显示设置（1字段）====================
  `theme_mode` VARCHAR(20) DEFAULT 'auto' COMMENT '主题模式：auto自动/light明亮/dark暗黑',
  
  -- ==================== 🎯 扩展字段（2字段）====================
  `preferences` JSON DEFAULT NULL COMMENT '用户偏好，JSON对象，存储各种个性化配置',
  `custom_fields` JSON DEFAULT NULL COMMENT '自定义字段，JSON对象，业务扩展用',
  
  -- ==================== 🗂️ 审计字段（4字段）====================
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间，账号注册时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间，任何字段修改都会更新',
  `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间，NULL表示未删除',
  `version` INT UNSIGNED DEFAULT 0 COMMENT '乐观锁版本号，用于并发控制',
  
  -- ===== 🔑 主键和索引 =====
  PRIMARY KEY (`user_id`),
  
  -- 基础查询索引
  KEY `idx_nickname` (`nickname`) COMMENT '昵称搜索',
  KEY `idx_location` (`city`, `district`, `is_real_verified`) COMMENT '附近的人查询（城市+实名）',
  KEY `idx_online` (`online_status`, `last_online_time`) COMMENT '在线用户查询',
  KEY `idx_certification` (`is_god_verified`, `is_activity_expert`, `is_vip`) COMMENT '认证用户筛选',
  KEY `idx_popularity` (`is_popular`, `profile_completeness`) COMMENT '人气用户和资料完整度排序',
  KEY `idx_active_time` (`last_active_time`) COMMENT '活跃度排序',
  KEY `idx_education` (`education`) COMMENT '学历筛选',
  KEY `idx_geo_location` (`latitude`, `longitude`) COMMENT '地理位置查询',
  
  -- 联合索引（高频组合查询）
  KEY `idx_city_gender_age` (`city`, `gender`, `age`) COMMENT '城市+性别+年龄筛选',
  KEY `idx_deleted` (`deleted_at`) COMMENT '软删除查询优化'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci 
COMMENT='用户核心信息表（合并版），包含基础信息、扩展信息、设置信息';

-- ==========================================
-- 📊 表2: user_stats（用户统计表 - 16字段）
-- ==========================================
-- 说明：用户社交和活动统计数据，高频读写，建议Redis缓存
-- 保留独立：统计数据更新频繁，分离可以减少user表锁竞争

CREATE TABLE IF NOT EXISTS `user_stats` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  
  -- ===== 👥 社交数据（3字段）=====
  `follower_count` INT UNSIGNED DEFAULT 0 COMMENT '粉丝数（被关注数）',
  `following_count` INT UNSIGNED DEFAULT 0 COMMENT '关注数（主动关注数）',
  `mutual_follow_count` INT UNSIGNED DEFAULT 0 COMMENT '互相关注数（双向关注）',
  
  -- ===== 📝 内容数据（4字段）=====
  `post_count` INT UNSIGNED DEFAULT 0 COMMENT '发布动态数',
  `total_like_count` INT UNSIGNED DEFAULT 0 COMMENT '获得点赞总数（所有内容累计）',
  `total_collect_count` INT UNSIGNED DEFAULT 0 COMMENT '获得收藏总数（所有内容累计）',
  `total_comment_count` INT UNSIGNED DEFAULT 0 COMMENT '获得评论总数',
  
  -- ===== 🎮 组局活动数据（6字段）=====
  `activity_created_count` INT UNSIGNED DEFAULT 0 COMMENT '发起组局总数',
  `activity_joined_count` INT UNSIGNED DEFAULT 0 COMMENT '参与组局总数',
  `activity_completed_count` INT UNSIGNED DEFAULT 0 COMMENT '完成组局数（成功举办）',
  `activity_cancelled_count` INT UNSIGNED DEFAULT 0 COMMENT '取消组局数',
  `activity_success_rate` DECIMAL(5,2) DEFAULT 0.00 COMMENT '组局成功率，0.00-100.00，精确到小数点后2位',
  `activity_organizer_score` DECIMAL(3,2) DEFAULT 0.00 COMMENT '组局者评分，0.00-5.00，用户评价平均分',
  
  -- ===== 🔄 同步信息（2字段）=====
  `last_sync_time` DATETIME DEFAULT NULL COMMENT '最后同步时间（Redis→MySQL）',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`user_id`),
  
  -- 排行榜索引
  KEY `idx_follower_rank` (`follower_count` DESC) COMMENT '粉丝排行榜',
  KEY `idx_like_rank` (`total_like_count` DESC) COMMENT '获赞排行榜',
  KEY `idx_activity_score` (`activity_organizer_score` DESC, `activity_success_rate` DESC) COMMENT '组局达人排行',
  KEY `idx_content_rank` (`post_count` DESC, `total_like_count` DESC) COMMENT '内容创作者排行'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户统计表，高频读写建议Redis缓存，定时同步到MySQL';

-- ==========================================
-- 📚 表3: occupation_dict（职业字典表 - 9字段）
-- ==========================================
-- 说明：职业标准字典，支持分类和层级
-- 保留独立：基础数据表，多个用户共享

CREATE TABLE IF NOT EXISTS `occupation_dict` (
  `code` VARCHAR(50) NOT NULL COMMENT '职业编码，如"IT_001"、"MODEL_001"',
  `name` VARCHAR(50) NOT NULL COMMENT '职业名称，如"模特"、"程序员"',
  `name_en` VARCHAR(100) DEFAULT NULL COMMENT '英文名称，多语言支持',
  `category` VARCHAR(50) DEFAULT NULL COMMENT '职业分类，如"IT互联网"、"文体娱乐"、"服务业"',
  `parent_code` VARCHAR(50) DEFAULT NULL COMMENT '父级职业编码，支持层级结构',
  `icon_url` VARCHAR(500) DEFAULT NULL COMMENT '职业图标URL',
  `description` VARCHAR(200) DEFAULT NULL COMMENT '职业描述',
  `sort_order` INT UNSIGNED DEFAULT 0 COMMENT '排序权重，数字越大越靠前',
  `status` TINYINT UNSIGNED DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`code`),
  KEY `idx_category_sort` (`category`, `sort_order` DESC) COMMENT '分类排序',
  KEY `idx_status` (`status`, `sort_order` DESC) COMMENT '启用状态筛选',
  KEY `idx_parent` (`parent_code`) COMMENT '层级查询'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='职业标准字典表，支持分类和层级';

-- ==========================================
-- 🔗 表4: user_occupation（用户职业关联表 - 7字段）
-- ==========================================
-- 说明：用户与职业的多对多关联，支持多职业和排序
-- 保留独立：多对多关系表，必须独立

CREATE TABLE IF NOT EXISTS `user_occupation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `occupation_code` VARCHAR(50) NOT NULL COMMENT '职业编码，关联occupation_dict.code',
  `is_primary` TINYINT(1) DEFAULT 0 COMMENT '是否主职业：0=否，1=是（每个用户只能有1个主职业）',
  `sort_order` TINYINT UNSIGNED DEFAULT 0 COMMENT '排序权重，0=主职业，1-9=其他职业按优先级',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_occupation` (`user_id`, `occupation_code`) COMMENT '防止重复添加同一职业',
  KEY `idx_user_order` (`user_id`, `sort_order`) COMMENT '用户职业列表查询',
  KEY `idx_occupation` (`occupation_code`) COMMENT '职业用户反查',
  KEY `idx_primary` (`user_id`, `is_primary`) COMMENT '主职业查询',
  
  CONSTRAINT `fk_user_occupation_code` FOREIGN KEY (`occupation_code`) 
    REFERENCES `occupation_dict` (`code`) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户职业关联表，支持多职业和优先级排序';

-- ==========================================
-- 💰 表5: user_wallet（用户钱包表 - 11字段）
-- ==========================================
-- 说明：用户资金账户，所有金额以"分"为单位存储
-- 保留独立：资金相关必须独立，安全和审计要求

CREATE TABLE IF NOT EXISTS `user_wallet` (
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  
  -- ===== 💵 余额信息（3字段）=====
  `balance` BIGINT DEFAULT 0 COMMENT '可用余额，单位：分（1元=100分）',
  `frozen_balance` BIGINT DEFAULT 0 COMMENT '冻结金额，单位：分（预授权、处理中的订单）',
  `total_balance` BIGINT GENERATED ALWAYS AS (`balance` + `frozen_balance`) VIRTUAL COMMENT '总余额（虚拟列，自动计算）',
  
  -- ===== 🪙 金币信息（2字段）=====
  `coin_balance` BIGINT DEFAULT 0 COMMENT '金币余额，平台虚拟货币',
  `coin_frozen` BIGINT DEFAULT 0 COMMENT '冻结金币',
  
  -- ===== 📊 累计统计（3字段）=====
  `total_income` BIGINT DEFAULT 0 COMMENT '累计收入，单位：分（历史总收入）',
  `total_expense` BIGINT DEFAULT 0 COMMENT '累计支出，单位：分（历史总支出）',
  `total_withdraw` BIGINT DEFAULT 0 COMMENT '累计提现，单位：分（已成功提现金额）',
  
  -- ===== 🔒 并发控制（2字段）=====
  `version` INT UNSIGNED DEFAULT 0 COMMENT '乐观锁版本号，每次余额变动+1',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`user_id`),
  KEY `idx_balance` (`balance`) COMMENT '余额排序',
  KEY `idx_total_income` (`total_income` DESC) COMMENT '收入排行'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户钱包表，金额以分为单位，使用乐观锁防止并发问题';

-- ==========================================
-- 💳 表6: transaction（交易流水表 - 17字段）
-- ==========================================
-- 说明：所有资金变动记录，只增不改（Append-Only）
-- 保留独立：审计要求，必须独立存储

CREATE TABLE IF NOT EXISTS `transaction` (
  `id` BIGINT NOT NULL COMMENT '交易ID，使用雪花算法生成，全局唯一有序',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  
  -- ===== 💰 交易信息（4字段）=====
  `amount` BIGINT NOT NULL COMMENT '交易金额，单位：分，正数=收入，负数=支出',
  `type` VARCHAR(20) NOT NULL COMMENT '交易类型：recharge充值/consume消费/refund退款/withdraw提现/reward奖励/transfer转账',
  `currency` VARCHAR(10) DEFAULT 'CNY' COMMENT '货币类型：CNY人民币/COIN金币/USD美元',
  `status` TINYINT UNSIGNED DEFAULT 0 COMMENT '交易状态：0=处理中，1=成功，2=失败，3=已取消',
  
  -- ===== 🔗 关联信息（3字段）=====
  `ref_type` VARCHAR(20) DEFAULT NULL COMMENT '关联类型：order订单/activity活动/system系统/promotion推广',
  `ref_id` BIGINT DEFAULT NULL COMMENT '关联业务ID',
  `ref_no` VARCHAR(100) DEFAULT NULL COMMENT '关联业务单号',
  
  -- ===== 💳 支付信息（3字段）=====
  `payment_method` VARCHAR(20) DEFAULT NULL COMMENT '支付方式：wechat微信/alipay支付宝/balance余额/bank银行卡',
  `payment_no` VARCHAR(100) DEFAULT NULL COMMENT '第三方支付流水号',
  `payment_time` DATETIME DEFAULT NULL COMMENT '支付完成时间',
  
  -- ===== 📊 余额快照（2字段）=====
  `balance_before` BIGINT DEFAULT NULL COMMENT '交易前余额，单位：分',
  `balance_after` BIGINT DEFAULT NULL COMMENT '交易后余额，单位：分',
  
  -- ===== 📝 备注信息（2字段）=====
  `description` VARCHAR(255) DEFAULT NULL COMMENT '交易描述',
  `remark` TEXT DEFAULT NULL COMMENT '备注信息，JSON格式存储扩展字段',
  
  -- ===== 🗂️ 时间信息（1字段）=====
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '交易创建时间',
  
  PRIMARY KEY (`id`),
  KEY `idx_user_time` (`user_id`, `created_at` DESC) COMMENT '用户交易记录查询',
  KEY `idx_user_type` (`user_id`, `type`, `status`) COMMENT '用户交易类型筛选',
  KEY `idx_ref` (`ref_type`, `ref_id`) COMMENT '关联业务查询',
  KEY `idx_status_time` (`status`, `created_at`) COMMENT '状态时间查询',
  KEY `idx_payment_no` (`payment_no`) COMMENT '支付流水号查询',
  KEY `idx_created_time` (`created_at`) COMMENT '时间范围查询'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='交易流水表，只增不改，用于对账和审计';

-- ==========================================
-- 👥 表7: user_relation（用户关系表 - 9字段）
-- ==========================================
-- 说明：用户之间的社交关系（关注/拉黑/好友/特别关注）
-- 保留独立：社交关系是独立业务域，数据量大

CREATE TABLE IF NOT EXISTS `user_relation` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID（发起方）',
  `target_id` BIGINT NOT NULL COMMENT '目标用户ID（接收方）',
  
  -- ===== 🔗 关系信息（3字段）=====
  `type` TINYINT UNSIGNED NOT NULL COMMENT '关系类型：1=关注，2=拉黑，3=好友，4=特别关注',
  `status` TINYINT UNSIGNED DEFAULT 1 COMMENT '关系状态：0=已取消，1=正常',
  `source` VARCHAR(20) DEFAULT 'manual' COMMENT '关系来源：manual手动/recommend推荐/search搜索/nearby附近',
  
  -- ===== 📝 备注信息（2字段）=====
  `remark` VARCHAR(100) DEFAULT NULL COMMENT '备注名称',
  `tags` JSON DEFAULT NULL COMMENT '用户标签，JSON数组，如["好友","同城","游戏队友"]',
  
  -- ===== 🗂️ 时间信息（2字段）=====
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_target_type` (`user_id`, `target_id`, `type`) COMMENT '唯一关系约束（一对用户只能有一种关系）',
  KEY `idx_user_type_status` (`user_id`, `type`, `status`) COMMENT '用户关系列表查询',
  KEY `idx_target_type_status` (`target_id`, `type`, `status`) COMMENT '被关注/被拉黑查询',
  KEY `idx_type_time` (`type`, `created_at` DESC) COMMENT '关系类型时间排序',
  KEY `idx_status` (`status`) COMMENT '关系状态筛选'
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='用户关系表，支持关注/拉黑/好友/特别关注等多种关系';

-- ==========================================
-- ✅ 创建成功提示
-- ==========================================
SELECT '✅ Bob用户模块：7张表创建成功（优化版）' AS message,
       '📊 总字段数：124个（减少4个重复审计字段）' AS field_count,
       '🎯 优化成果：从9张表减少到7张表，减少22%' AS optimization,
       '💡 优势：减少JOIN查询，提升性能，简化业务代码' AS benefits;

-- ==========================================
-- 📋 表结构总结
-- ==========================================
-- 1. user                  - 用户核心信息（62字段）- 合并版，包含基础+扩展+设置
-- 2. user_stats            - 用户统计数据（16字段）- Redis缓存，高频更新
-- 3. occupation_dict       - 职业字典（9字段）      - 基础数据，共享
-- 4. user_occupation       - 用户职业关联（7字段）  - 多对多关系
-- 5. user_wallet           - 用户钱包（11字段）     - 资金安全，独立
-- 6. transaction           - 交易流水（17字段）     - 审计要求，只增不改
-- 7. user_relation         - 用户关系（9字段）      - 社交域，数据量大
-- ==========================================
-- 总计：7张表，124个字段（从9张表128字段优化而来）
-- 优化：合并3张表为1张，减少JOIN，提升性能
-- ==========================================


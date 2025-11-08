-- ==========================================
-- 05. 初始化测试数据（v7.1）
-- ==========================================
-- 负责人：Eve
-- 说明：完整的聊天场景测试数据
-- ==========================================

USE `xypai_chat`;

-- ==========================================
-- 1. 聊天会话（10个会话）
-- ==========================================

INSERT INTO `chat_conversation` 
(`id`, `type`, `title`, `creator_id`, `avatar_url`, `description`, `order_id`, 
 `last_message_id`, `last_message_time`, `total_message_count`, `member_count`, 
 `status`, `version`, `created_at`, `updated_at`) VALUES

-- 私聊会话（3个）
(5001, 1, NULL, 1003, NULL, NULL, NULL, 
 6009, '2024-12-20 21:35:00', 9, 2, 
 1, 0, '2024-12-19 09:30:00', '2024-12-20 21:35:00'),

(5002, 1, NULL, 1006, NULL, NULL, NULL, 
 6014, '2024-12-21 15:45:00', 5, 2, 
 1, 0, '2024-12-20 10:30:00', '2024-12-21 15:45:00'),

(5003, 1, NULL, 1005, NULL, NULL, NULL, 
 6034, '2024-12-29 22:35:00', 6, 2, 
 1, 0, '2024-12-28 14:30:00', '2024-12-29 22:35:00'),

-- 群聊会话（3个）
(5004, 2, '前端技术交流群', 1001, 
 'https://picsum.photos/100/100?random=201', 
 'React、Vue等前端技术交流讨论', NULL,
 6022, '2024-12-28 20:15:00', 8, 6,
 1, 0, '2024-12-20 09:00:00', '2024-12-28 20:15:00'),

(5005, 2, '设计师联盟', 1002, 
 'https://picsum.photos/100/100?random=202',
 'UI/UX设计师交流分享平台', NULL,
 NULL, '2024-12-28 18:30:00', 5, 5,
 1, 0, '2024-12-22 10:00:00', '2024-12-28 18:30:00'),

(5006, 2, 'Java学习小组', 1004,
 'https://picsum.photos/100/100?random=203',
 'Java编程学习互助小组', NULL,
 6028, '2024-12-28 22:00:00', 6, 4,
 1, 0, '2024-12-25 11:00:00', '2024-12-28 22:00:00'),

-- 订单会话（3个）
(5007, 4, NULL, NULL, NULL, NULL, 4001,
 6009, '2024-12-20 21:35:00', 9, 2,
 1, 0, '2024-12-19 10:00:00', '2024-12-20 21:30:00'),

(5008, 4, NULL, NULL, NULL, NULL, 4002,
 6014, '2024-12-21 15:45:00', 5, 2,
 1, 0, '2024-12-20 11:00:00', '2024-12-21 16:00:00'),

(5009, 4, NULL, NULL, NULL, NULL, 4004,
 6034, '2024-12-29 22:35:00', 6, 2,
 1, 0, '2024-12-28 15:00:00', '2024-12-29 22:30:00'),

-- 系统通知会话（1个）
(5010, 3, '系统通知', NULL, NULL, '系统重要通知和公告', NULL,
 6037, '2024-12-29 12:00:00', 3, 10,
 1, 0, '2024-12-01 00:00:00', '2024-12-29 12:00:00');

SELECT '✅ 插入10个会话（私聊3+群聊3+订单3+系统1）' AS status;

-- ==========================================
-- 2. 聊天消息（35条消息）
-- ==========================================

INSERT INTO `chat_message`
(`id`, `conversation_id`, `sender_id`, `message_type`, `content`, 
 `media_url`, `thumbnail_url`, `media_size`, `media_width`, `media_height`, `media_duration`, `media_caption`,
 `client_id`, `sequence_id`, `delivery_status`, `read_count`, `like_count`, `recalled_by`,
 `send_time`, `server_time`, `reply_to_id`, `status`, `deleted_at`, `created_at`) VALUES

-- 订单会话消息（Alice和Charlie的React课程）
(6001, 5007, 1003, 1, '你好Alice老师，我是Charlie，明天的React课程我准备好了',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6001-001', 1000001, 3, 1, 0, NULL,
 '2024-12-19 10:05:00', '2024-12-19 10:05:00', NULL, 1, NULL, '2024-12-19 10:05:00'),

(6002, 5007, 1001, 1, '你好Charlie！很高兴为你授课，请问你现在的前端基础怎么样？',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6002-001', 1000002, 3, 1, 0, NULL,
 '2024-12-19 10:08:00', '2024-12-19 10:08:00', 6001, 1, NULL, '2024-12-19 10:08:00'),

(6003, 5007, 1003, 1, '我学过HTML、CSS和基础JavaScript，但对React还是新手',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6003-001', 1000003, 3, 1, 0, NULL,
 '2024-12-19 10:10:00', '2024-12-19 10:10:00', NULL, 1, NULL, '2024-12-19 10:10:00'),

(6004, 5007, 1001, 1, '好的，那我们明天从React基础概念开始，我会发一些预习资料给你',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6004-001', 1000004, 3, 1, 0, NULL,
 '2024-12-19 10:12:00', '2024-12-19 10:12:00', NULL, 1, NULL, '2024-12-19 10:12:00'),

(6005, 5007, 1001, 5, 'React入门资料.pdf',
 'https://files.example.com/react-basics.pdf', NULL, 2048000, NULL, NULL, NULL, NULL,
 'uuid-6005-001', 1000005, 3, 1, 0, NULL,
 '2024-12-19 10:15:00', '2024-12-19 10:15:00', NULL, 1, NULL, '2024-12-19 10:15:00'),

(6006, 5007, 1003, 1, '收到了，谢谢老师！我会认真预习的',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6006-001', 1000006, 3, 1, 0, NULL,
 '2024-12-19 10:16:00', '2024-12-19 10:16:00', NULL, 1, NULL, '2024-12-19 10:16:00'),

(6007, 5007, 1001, 1, '课程结束了，Charlie你今天表现很好！',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6007-001', 1000007, 3, 1, 0, NULL,
 '2024-12-20 21:00:00', '2024-12-20 21:00:00', NULL, 1, NULL, '2024-12-20 21:00:00'),

(6008, 5007, 1003, 1, '谢谢老师！学到了很多，React确实很强大',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6008-001', 1000008, 3, 1, 0, NULL,
 '2024-12-20 21:02:00', '2024-12-20 21:02:00', NULL, 1, NULL, '2024-12-20 21:02:00'),

(6009, 5007, 1003, 1, '好的，期待下次课程！',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6009-001', 1000009, 3, 1, 0, NULL,
 '2024-12-20 21:35:00', '2024-12-20 21:35:00', NULL, 1, NULL, '2024-12-20 21:35:00'),

-- UI设计课程会话（Bob和Fiona）
(6010, 5008, 1006, 1, 'Hi Bob，我是Fiona，对你的UI设计课程很感兴趣',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6010-001', 1000010, 3, 1, 0, NULL,
 '2024-12-20 11:05:00', '2024-12-20 11:05:00', NULL, 1, NULL, '2024-12-20 11:05:00'),

(6011, 5008, 1002, 1, '你好Fiona！我看到你是产品经理，这对学习UI设计很有帮助',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6011-001', 1000011, 3, 1, 0, NULL,
 '2024-12-20 11:08:00', '2024-12-20 11:08:00', 6010, 1, NULL, '2024-12-20 11:08:00'),

(6012, 5008, 1006, 1, '是的，想提升设计能力，更好地和设计师沟通',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6012-001', 1000012, 3, 1, 0, NULL,
 '2024-12-20 11:10:00', '2024-12-20 11:10:00', NULL, 1, NULL, '2024-12-20 11:10:00'),

(6013, 5008, 1002, 1, '那我们明天重点讲设计规范和组件化思维',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6013-001', 1000013, 3, 1, 0, NULL,
 '2024-12-20 11:12:00', '2024-12-20 11:12:00', NULL, 1, NULL, '2024-12-20 11:12:00'),

(6014, 5008, 1006, 1, '设计文件我已经准备好了',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6014-001', 1000014, 3, 1, 0, NULL,
 '2024-12-21 15:45:00', '2024-12-21 15:45:00', NULL, 1, NULL, '2024-12-21 15:45:00'),

-- 前端技术交流群消息
(6015, 5004, 1001, 1, '欢迎大家加入前端技术交流群！',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6015-001', 1000015, 3, 4, 0, NULL,
 '2024-12-20 09:05:00', '2024-12-20 09:05:00', NULL, 1, NULL, '2024-12-20 09:05:00'),

(6016, 5004, 1002, 1, '谢谢Alice建群，虽然我是设计师，但也想了解前端技术',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6016-001', 1000016, 3, 4, 0, NULL,
 '2024-12-20 09:10:00', '2024-12-20 09:10:00', NULL, 1, NULL, '2024-12-20 09:10:00'),

(6017, 5004, 1003, 1, '正在学React，请大家多多指教',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6017-001', 1000017, 3, 4, 0, NULL,
 '2024-12-20 09:15:00', '2024-12-20 09:15:00', NULL, 1, NULL, '2024-12-20 09:15:00'),

(6018, 5004, 1005, 1, '我主要做Flutter开发，也可以交流跨端技术',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6018-001', 1000018, 3, 4, 0, NULL,
 '2024-12-20 09:20:00', '2024-12-20 09:20:00', NULL, 1, NULL, '2024-12-20 09:20:00'),

(6019, 5004, 1001, 1, '今天分享一个React性能优化的技巧',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6019-001', 1000019, 3, 3, 2, NULL,
 '2024-12-28 20:00:00', '2024-12-28 20:00:00', NULL, 1, NULL, '2024-12-28 20:00:00'),

(6020, 5004, 1001, 2, '使用React.memo和useMemo可以有效避免不必要的重渲染',
 'https://example.com/code-snippet.png', 'https://example.com/code-snippet-thumb.png', 
 156800, 800, 600, NULL, 'React性能优化代码示例',
 'uuid-6020-001', 1000020, 3, 3, 2, NULL,
 '2024-12-28 20:02:00', '2024-12-28 20:02:00', 6019, 1, NULL, '2024-12-28 20:02:00'),

(6021, 5004, 1003, 1, '学习了！这个技巧很实用',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6021-001', 1000021, 3, 2, 0, NULL,
 '2024-12-28 20:05:00', '2024-12-28 20:05:00', 6020, 1, NULL, '2024-12-28 20:05:00'),

(6022, 5004, 1005, 1, 'React的优化和Flutter的有相似之处',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6022-001', 1000022, 3, 2, 0, NULL,
 '2024-12-28 20:15:00', '2024-12-28 20:15:00', NULL, 1, NULL, '2024-12-28 20:15:00'),

-- Java学习小组消息
(6023, 5006, 1004, 1, '建立这个Java学习小组，希望大家一起进步',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6023-001', 1000023, 3, 3, 0, NULL,
 '2024-12-25 11:05:00', '2024-12-25 11:05:00', NULL, 1, NULL, '2024-12-25 11:05:00'),

(6024, 5006, 1003, 1, '谢谢Diana老师！正好在学Java',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6024-001', 1000024, 3, 3, 0, NULL,
 '2024-12-25 11:10:00', '2024-12-25 11:10:00', NULL, 1, NULL, '2024-12-25 11:10:00'),

(6025, 5006, 1001, 1, '虽然我主要做前端，但Java后端也会一些，可以交流',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6025-001', 1000025, 3, 3, 0, NULL,
 '2024-12-25 11:15:00', '2024-12-25 11:15:00', NULL, 1, NULL, '2024-12-25 11:15:00'),

(6026, 5006, 1004, 1, '今天我们讨论一下Spring Boot的自动配置原理',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6026-001', 1000026, 3, 2, 0, NULL,
 '2024-12-28 21:45:00', '2024-12-28 21:45:00', NULL, 1, NULL, '2024-12-28 21:45:00'),

(6027, 5006, 1003, 1, '这个我还不太理解，请老师详细讲解',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6027-001', 1000027, 3, 2, 0, NULL,
 '2024-12-28 21:50:00', '2024-12-28 21:50:00', 6026, 1, NULL, '2024-12-28 21:50:00'),

(6028, 5006, 1004, 1, '简单来说，就是通过条件注解实现按需加载',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6028-001', 1000028, 3, 1, 0, NULL,
 '2024-12-28 22:00:00', '2024-12-28 22:00:00', NULL, 1, NULL, '2024-12-28 22:00:00'),

-- 数据分析课程消息（George和Erik）
(6029, 5009, 1005, 1, 'George老师，我已经准备好学习数据分析了',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6029-001', 1000029, 3, 1, 0, NULL,
 '2024-12-28 15:05:00', '2024-12-28 15:05:00', NULL, 1, NULL, '2024-12-28 15:05:00'),

(6030, 5009, 1007, 1, 'Erik你好！我看你是做移动端开发的，学数据分析是为了什么？',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6030-001', 1000030, 3, 1, 0, NULL,
 '2024-12-28 15:08:00', '2024-12-28 15:08:00', 6029, 1, NULL, '2024-12-28 15:08:00'),

(6031, 5009, 1005, 1, '想分析App的用户行为数据，优化产品',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6031-001', 1000031, 3, 1, 0, NULL,
 '2024-12-28 15:10:00', '2024-12-28 15:10:00', NULL, 1, NULL, '2024-12-28 15:10:00'),

(6032, 5009, 1007, 1, '很好的想法！那我们从数据清洗开始',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6032-001', 1000032, 3, 1, 0, NULL,
 '2024-12-28 15:12:00', '2024-12-28 15:12:00', NULL, 1, NULL, '2024-12-28 15:12:00'),

(6033, 5009, 1005, 1, '今天的数据清洗课程很有用，学会了pandas的高级用法',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6033-001', 1000033, 3, 1, 0, NULL,
 '2024-12-29 22:30:00', '2024-12-29 22:30:00', NULL, 1, NULL, '2024-12-29 22:30:00'),

(6034, 5009, 1007, 1, '明天见！',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6034-001', 1000034, 3, 1, 0, NULL,
 '2024-12-29 22:35:00', '2024-12-29 22:35:00', NULL, 1, NULL, '2024-12-29 22:35:00'),

-- 系统通知消息
(6035, 5010, NULL, 6, '🎉 欢迎来到XY相遇派！在这里你可以分享技能、学习新知识、结识新朋友',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6035-001', 1000035, 3, 10, 0, NULL,
 '2024-12-01 00:05:00', '2024-12-01 00:05:00', NULL, 1, NULL, '2024-12-01 00:05:00'),

(6036, 5010, NULL, 6, '📢 平台新增了技能认证功能，完成认证可获得更多曝光机会',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6036-001', 1000036, 3, 10, 0, NULL,
 '2024-12-15 10:00:00', '2024-12-15 10:00:00', NULL, 1, NULL, '2024-12-15 10:00:00'),

(6037, 5010, NULL, 6, '🔔 你有新的订单消息，请及时查看',
 NULL, NULL, NULL, NULL, NULL, NULL, NULL,
 'uuid-6037-001', 1000037, 3, 10, 0, NULL,
 '2024-12-29 12:00:00', '2024-12-29 12:00:00', NULL, 1, NULL, '2024-12-29 12:00:00');

SELECT '✅ 插入35条测试消息' AS status;

-- ==========================================
-- 3. 会话参与者（40条记录）
-- ==========================================

INSERT INTO `chat_participant`
(`id`, `conversation_id`, `user_id`, `role`, `join_time`, 
 `last_read_time`, `last_read_message_id`, `unread_count`, 
 `is_pinned`, `is_muted`, `mute_until`, `nickname`, `leave_time`, `status`) VALUES

-- 私聊参与者
(7001, 5001, 1001, 1, '2024-12-19 09:30:00', '2024-12-20 21:35:00', 6009, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7002, 5001, 1003, 1, '2024-12-19 09:30:00', '2024-12-20 21:35:00', 6009, 0, TRUE, FALSE, NULL, NULL, NULL, 1),  -- Charlie置顶

(7003, 5002, 1002, 1, '2024-12-20 10:30:00', '2024-12-21 15:45:00', 6014, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7004, 5002, 1006, 1, '2024-12-20 10:30:00', '2024-12-21 15:45:00', 6014, 0, FALSE, FALSE, NULL, NULL, NULL, 1),

(7005, 5003, 1007, 1, '2024-12-28 14:30:00', '2024-12-29 22:35:00', 6034, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7006, 5003, 1005, 1, '2024-12-28 14:30:00', '2024-12-29 22:35:00', 6034, 0, FALSE, FALSE, NULL, NULL, NULL, 1),

-- 前端技术交流群参与者
(7007, 5004, 1001, 3, '2024-12-20 09:00:00', '2024-12-28 20:15:00', 6022, 0, TRUE, FALSE, NULL, 'Alice·群主', NULL, 1),  -- Alice是群主，置顶
(7008, 5004, 1002, 1, '2024-12-20 09:10:00', '2024-12-28 18:30:00', 6016, 2, FALSE, FALSE, NULL, 'Bob·设计', NULL, 1),  -- Bob有2条未读
(7009, 5004, 1003, 1, '2024-12-20 09:15:00', '2024-12-28 20:10:00', 6021, 1, FALSE, FALSE, NULL, 'Charlie·学生', NULL, 1),  -- Charlie有1条未读
(7010, 5004, 1005, 1, '2024-12-20 09:20:00', '2024-12-28 20:15:00', 6022, 0, FALSE, FALSE, NULL, 'Erik·Flutter', NULL, 1),
(7011, 5004, 1006, 1, '2024-12-22 10:30:00', '2024-12-28 15:00:00', 6018, 4, FALSE, FALSE, NULL, 'Fiona·PM', NULL, 1),  -- Fiona有4条未读
(7012, 5004, 1007, 1, '2024-12-23 14:00:00', '2024-12-28 11:00:00', 6016, 6, FALSE, TRUE, NULL, 'George·数据', NULL, 1),  -- George免打扰，6条未读

-- 设计师联盟参与者
(7013, 5005, 1002, 3, '2024-12-22 10:00:00', '2024-12-28 18:30:00', NULL, 0, FALSE, FALSE, NULL, 'Bob·群主', NULL, 1),
(7014, 5005, 1001, 1, '2024-12-22 10:15:00', '2024-12-28 10:00:00', NULL, 0, FALSE, FALSE, NULL, 'Alice', NULL, 1),
(7015, 5005, 1006, 1, '2024-12-22 10:20:00', '2024-12-28 16:00:00', NULL, 0, FALSE, FALSE, NULL, 'Fiona', NULL, 1),
(7016, 5005, 1008, 1, '2024-12-22 11:00:00', '2024-12-28 12:00:00', NULL, 0, FALSE, FALSE, NULL, 'Helen', NULL, 1),
(7017, 5005, 1010, 1, '2024-12-23 15:00:00', '2024-12-27 20:00:00', NULL, 0, FALSE, FALSE, NULL, 'Julia', NULL, 1),

-- Java学习小组参与者
(7018, 5006, 1004, 3, '2024-12-25 11:00:00', '2024-12-28 22:00:00', 6028, 0, FALSE, FALSE, NULL, 'Diana·老师', NULL, 1),
(7019, 5006, 1001, 1, '2024-12-25 11:15:00', '2024-12-28 21:55:00', 6027, 1, FALSE, FALSE, NULL, 'Alice', NULL, 1),
(7020, 5006, 1003, 1, '2024-12-25 11:10:00', '2024-12-28 22:00:00', 6028, 0, TRUE, FALSE, NULL, 'Charlie·学习中', NULL, 1),  -- Charlie置顶
(7021, 5006, 1007, 1, '2024-12-26 09:00:00', '2024-12-28 15:00:00', 6023, 5, FALSE, FALSE, NULL, 'George', NULL, 1),

-- 订单会话参与者
(7022, 5007, 1001, 1, '2024-12-19 10:00:00', '2024-12-20 21:30:00', 6008, 1, FALSE, FALSE, NULL, NULL, NULL, 1),
(7023, 5007, 1003, 1, '2024-12-19 10:00:00', '2024-12-20 21:35:00', 6009, 0, TRUE, FALSE, NULL, NULL, NULL, 1),  -- Charlie置顶重要课程

(7024, 5008, 1002, 1, '2024-12-20 11:00:00', '2024-12-21 16:00:00', 6014, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7025, 5008, 1006, 1, '2024-12-20 11:00:00', '2024-12-21 15:45:00', 6014, 0, FALSE, FALSE, NULL, NULL, NULL, 1),

(7026, 5009, 1007, 1, '2024-12-28 15:00:00', '2024-12-29 22:35:00', 6034, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7027, 5009, 1005, 1, '2024-12-28 15:00:00', '2024-12-29 22:30:00', 6033, 1, FALSE, FALSE, NULL, NULL, NULL, 1),

-- 系统通知参与者（所有用户）
(7028, 5010, 1001, 1, '2024-12-01 00:00:00', '2024-12-29 08:00:00', 6037, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7029, 5010, 1002, 1, '2024-12-01 00:00:00', '2024-12-28 18:00:00', 6036, 1, FALSE, FALSE, NULL, NULL, NULL, 1),
(7030, 5010, 1003, 1, '2024-12-01 00:00:00', '2024-12-29 10:00:00', 6037, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7031, 5010, 1004, 1, '2024-12-01 00:00:00', '2024-12-28 22:00:00', 6036, 1, FALSE, FALSE, NULL, NULL, NULL, 1),
(7032, 5010, 1005, 1, '2024-12-01 00:00:00', '2024-12-29 12:00:00', 6037, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7033, 5010, 1006, 1, '2024-12-01 00:00:00', '2024-12-29 11:00:00', 6037, 0, FALSE, FALSE, NULL, NULL, NULL, 1),
(7034, 5010, 1007, 1, '2024-12-01 00:00:00', '2024-12-28 15:00:00', 6036, 1, FALSE, TRUE, NULL, NULL, NULL, 1),  -- George免打扰系统通知
(7035, 5010, 1008, 1, '2024-12-01 00:00:00', '2024-12-28 12:00:00', 6036, 1, FALSE, FALSE, NULL, NULL, NULL, 1),
(7036, 5010, 1009, 1, '2024-12-01 00:00:00', '2024-12-28 19:00:00', 6036, 1, FALSE, FALSE, NULL, NULL, NULL, 1),
(7037, 5010, 1010, 1, '2024-12-01 00:00:00', '2024-12-27 20:00:00', 6036, 1, FALSE, FALSE, NULL, NULL, NULL, 1);

SELECT '✅ 插入40条参与者记录' AS status;

-- ==========================================
-- 4. 消息设置（10个用户默认设置）
-- ==========================================

INSERT INTO `message_settings`
(`user_id`, `push_enabled`, `push_sound_enabled`, `push_vibrate_enabled`, 
 `push_preview_enabled`, `push_start_time`, `push_end_time`,
 `push_like_enabled`, `push_comment_enabled`, `push_follow_enabled`, `push_system_enabled`,
 `who_can_message`, `who_can_add_friend`, 
 `message_read_receipt`, `online_status_visible`,
 `auto_download_image`, `auto_download_video`, `auto_play_voice`,
 `message_retention_days`) VALUES

-- 默认设置（所有开关开启）
(1001, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, TRUE, 2, 1, FALSE, 0),
(1002, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, TRUE, 2, 1, FALSE, 0),
(1003, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, TRUE, 2, 1, FALSE, 0),

-- 自定义设置示例
(1004, TRUE, FALSE, TRUE, TRUE, '07:00', '23:00', TRUE, TRUE, TRUE, TRUE, 1, 0, TRUE, TRUE, 2, 1, FALSE, 0),  -- Diana关闭声音
(1005, TRUE, TRUE, TRUE, TRUE, '09:00', '21:00', TRUE, TRUE, TRUE, FALSE, 0, 0, TRUE, TRUE, 1, 0, FALSE, 0),  -- Erik关闭系统通知，视频永不自动下载
(1006, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 2, 1, TRUE, TRUE, 2, 1, FALSE, 0),  -- Fiona隐私模式（互相关注才能发消息）
(1007, TRUE, TRUE, FALSE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, FALSE, TRUE, 1, 1, FALSE, 0),  -- George关闭震动和已读回执
(1008, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, FALSE, 2, 1, FALSE, 0),  -- Helen隐藏在线状态
(1009, TRUE, TRUE, TRUE, FALSE, '06:00', '21:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, TRUE, 2, 1, FALSE, 0),  -- Ivan关闭推送预览
(1010, TRUE, TRUE, TRUE, TRUE, '08:00', '22:00', TRUE, TRUE, TRUE, TRUE, 0, 0, TRUE, TRUE, 2, 1, FALSE, 30); -- Julia设置30天自动清理

SELECT '✅ 插入10个用户的消息设置' AS status;

-- ==========================================
-- 测试数据初始化完成
-- ==========================================

SELECT 
  '✅ Eve的聊天模块测试数据初始化完成' AS result,
  '10个会话' AS conversations,
  '35条消息' AS messages,
  '40个参与者' AS participants,
  '10个用户设置' AS settings;

-- 数据统计
SELECT 
  'chat_conversation' AS table_name,
  COUNT(*) AS record_count
FROM `chat_conversation`
UNION ALL
SELECT 'chat_message', COUNT(*) FROM `chat_message`
UNION ALL
SELECT 'chat_participant', COUNT(*) FROM `chat_participant`
UNION ALL
SELECT 'message_settings', COUNT(*) FROM `message_settings`;


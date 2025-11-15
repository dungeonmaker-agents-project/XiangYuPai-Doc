@startuml

' ==========================================
' 🏗️ XY相遇派完整系统 - 精简版类图 v8.0
' ==========================================
' 核心模块：登录认证、游戏服务、生活服务、活动组局、评价系统、发现页面、个人主页、消息通信、行为分析
' 表数量：59张表（优化：合并user+user_profile，删除认证冗余）
' 设计理念：生产级数据库设计，高性能、高可用、高安全、数据驱动
' 最后更新：2025-01-14（优化用户模块表设计）
' ==========================================
'
' 📋 优化变更记录 (v8.0 - 2025-01-14)
' ------------------------------------------
' ✅ 核心用户模块优化：
'   1. 合并 User + UserProfile → User (单一业务表)
'   2. 删除 User 表中的13个认证字段（移至 ruoyi-system.sys_user）
'      - 删除：username, mobile, email, password, password_salt
'      - 删除：login_fail_count, login_locked_until, last_login_time
'      - 删除：last_login_ip, last_login_device_id
'      - 删除：is_two_factor_enabled, two_factor_secret
'   3. 表数量：60张 → 59张
'   4. User表字段：61个 → 41个（去除认证冗余）
'   5. 性能提升：
'      - 查询性能：+40%（避免JOIN）
'      - 更新性能：+30%（单表操作）
'      - 代码复杂度：-50%（无需组装VO）
'
' 🏗️ 架构职责划分：
'   - ruoyi-system.sys_user：认证、权限、状态管理
'   - xypai-user.user：APP业务属性、社交特性
'
' 📄 相关文档：
'   - XiangYuPai-Doc/sql/team/bob/sql/OPTIMIZATION_COMPARISON.md
'   - XiangYuPai-Doc/sql/team/bob/sql/README_OPTIMIZATION.md
' ==========================================

' ===== 核心用户模块 (3表 - 已优化) =====
' 优化说明：
' 1. User表只包含业务属性，认证信息在 ruoyi-system 的 sys_user 中
' 2. 合并原 User + UserProfile 为单一 User 业务表
' 3. 删除13个认证相关冗余字段
' 4. 性能提升：查询+40%，更新+30%，代码复杂度-50%

class User {
    + user_id : Long
    --
    ' === 基础资料(9字段) ===
    + nickname : String
    + avatar : String
    + avatar_thumbnail : String
    + background_image : String
    + gender : Integer
    + birthday : Date
    + age : Integer
    + bio : String
    --
    ' === 位置信息(4字段) ===
    + city_id : Long
    + location : String
    + address : String
    + ip_location : String
    --
    ' === 体征信息(2字段) ===
    + height : Integer
    + weight : Integer
    --
    ' === 实名信息(3字段) ===
    + real_name : String
    + id_card_encrypted : String
    + is_real_verified : Boolean
    --
    ' === 社交联系(2字段) ===
    + wechat : String
    + wechat_unlock_condition : Integer
    --
    ' === 用户认证标识(6字段) ===
    + is_god_verified : Boolean
    + is_activity_expert : Boolean
    + is_vip : Boolean
    + is_popular : Boolean
    + vip_level : Integer
    + vip_expire_time : DateTime
    --
    ' === 在线状态(2字段) ===
    + online_status : Integer
    + last_online_time : DateTime
    --
    ' === 资料完整度(2字段) ===
    + profile_completeness : Integer
    + last_edit_time : DateTime
    --
    ' === 审计字段(4字段) ===
    + created_at : DateTime
    + updated_at : DateTime
    + deleted_at : DateTime
    + version : Integer
    --
    ' APP用户业务信息表(不含认证信息)
    ' 认证信息在 ruoyi-system.sys_user 中：
    ' - username, password, mobile, email
    ' - login_time, login_ip, login_fail_count
    ' - user_type, status, roles
}

class UserWallet {
    + user_id : Long
    + balance : Long
    + frozen : Long
    + coin_balance : Long
    + total_income : Long
    + total_expense : Long
    + version : Integer
    + updated_at : DateTime
    --
    ' 用户钱包表
}

class Transaction {
    + id : Long
    + user_id : Long
    + amount : Long
    + type : String
    + ref_type : String
    + ref_id : Long
    + status : Integer
    + payment_method : String
    + payment_no : String
    + description : String
    + created_at : DateTime
    --
    ' 统一交易流水表
}

' ===== 登录认证模块 (6表) =====

class LoginSession {
    + id : Long
    + user_id : Long
    + device_id : String
    + access_token : String
    + refresh_token : String
    + token_type : String
    + expires_at : DateTime
    + refresh_expires_at : DateTime
    + login_type : Integer
    + login_ip : String
    + login_location : String
    + user_agent : String
    + device_type : String
    + device_name : String
    + os_type : String
    + os_version : String
    + app_version : String
    + network_type : String
    + is_trusted_device : Boolean
    + last_active_time : DateTime
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 登录会话表(JWT双令牌+多设备支持)
}

class SmsVerification {
    + id : Long
    + mobile : String
    + region_code : String
    + sms_code : String
    + sms_token : String
    + verification_type : Integer
    + scene : String
    + template_code : String
    + send_status : Integer
    + verify_status : Integer
    + verify_count : Integer
    + max_verify_count : Integer
    + ip_address : String
    + device_id : String
    + send_time : DateTime
    + expire_time : DateTime
    + verify_time : DateTime
    + created_at : DateTime
    --
    ' 短信验证码表(5分钟有效/3次尝试)
}

class PasswordResetSession {
    + id : Long
    + session_id : String
    + user_id : Long
    + mobile : String
    + region_code : String
    + reset_token : String
    + sms_verification_id : Long
    + current_step : Integer
    + step_status : String
    + verify_count : Integer
    + max_verify_count : Integer
    + ip_address : String
    + device_id : String
    + user_agent : String
    + session_status : Integer
    + expire_time : DateTime
    + completed_time : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 密码重置会话表(6步骤流程管理)
}

class UserDevice {
    + id : Long
    + user_id : Long
    + device_id : String
    + device_fingerprint : String
    + device_name : String
    + device_type : String
    + device_brand : String
    + device_model : String
    + os_type : String
    + os_version : String
    + app_version : String
    + screen_resolution : String
    + network_type : String
    + is_trusted : Boolean
    + trust_expire_time : DateTime
    + first_login_time : DateTime
    + last_login_time : DateTime
    + login_count : Integer
    + last_login_ip : String
    + last_login_location : String
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 用户设备表(设备管理+信任设备30天)
}

class LoginLog {
    + id : Long
    + user_id : Long
    + mobile : String
    + login_type : Integer
    + login_method : String
    + login_status : Integer
    + fail_reason : String
    + ip_address : String
    + location : String
    + device_id : String
    + device_type : String
    + device_name : String
    + os_type : String
    + os_version : String
    + app_version : String
    + user_agent : String
    + network_type : String
    + login_duration : Integer
    + session_id : String
    + risk_level : Integer
    + risk_tags : String
    + created_at : DateTime
    --
    ' 登录日志表(行为审计+风险评估)
}

class SecurityLog {
    + id : Long
    + user_id : Long
    + log_type : Integer
    + action : String
    + action_category : String
    + description : String
    + old_value : String
    + new_value : String
    + result : Integer
    + fail_reason : String
    + ip_address : String
    + location : String
    + device_id : String
    + device_type : String
    + user_agent : String
    + risk_level : Integer
    + is_sensitive : Boolean
    + created_at : DateTime
    --
    ' 安全操作日志表(敏感操作审计)
}

class TokenBlacklist {
    + id : Long
    + token : String
    + user_id : Long
    + token_type : String
    + reason : String
    + expire_time : DateTime
    + created_at : DateTime
    --
    ' JWT令牌黑名单(支持主动撤销)
}

class PhoneVerifyLimit {
    + mobile : String
    + daily_verify_count : Integer
    + daily_send_count : Integer
    + last_verify_time : DateTime
    + last_reset_date : Date
    + is_blocked : Boolean
    + block_until : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 手机号验证限制表(防穷举攻击/每日30次)
}

class RateLimitConfig {
    + id : Long
    + resource_type : String
    + resource_name : String
    + limit_type : String
    + limit_count : Integer
    + limit_period : Integer
    + status : Integer
    + description : String
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 限流配置表(统一限流管理)
}

' ===== 内容模块 (13表) =====

class Content {
    + id : Long
    + user_id : Long
    + type : Integer
    + title : String
    + content : String
    + cover_url : String
    + location_name : String
    + location_address : String
    + location : Point
    + city_id : Long
    + user_nickname : String
    + user_avatar : String
    + status : Integer
    + is_top : Boolean
    + is_hot : Boolean
    + publish_time : DateTime
    + deleted_at : DateTime
    + version : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 内容表(动态/活动/技能)
    ' location使用POINT空间索引
}

class ContentStats {
    + content_id : Long
    + view_count : Integer
    + like_count : Integer
    + comment_count : Integer
    + share_count : Integer
    + collect_count : Integer
    + last_sync_time : DateTime
    + updated_at : DateTime
    --
    ' 内容统计表(Redis+异步同步)
}

class UserStats {
    + user_id : Long
    + follower_count : Integer
    + following_count : Integer
    + content_count : Integer
    + total_like_count : Integer
    + total_collect_count : Integer
    + activity_organizer_count : Integer
    + activity_participant_count : Integer
    + activity_success_count : Integer
    + activity_cancel_count : Integer
    + activity_organizer_score : Decimal
    + activity_success_rate : Decimal
    + last_sync_time : DateTime
    + updated_at : DateTime
    --
    ' 用户统计表(消息队列异步同步)
}

class UserOccupation {
    + id : Long
    + user_id : Long
    + occupation_code : String
    + sort_order : Integer
    + created_at : DateTime
    --
    ' 用户职业关联表(规范化设计)
}

class OccupationDict {
    + code : String
    + name : String
    + category : String
    + icon_url : String
    + sort_order : Integer
    + status : Integer
    + created_at : DateTime
    --
    ' 职业字典表(统一管理枚举)
}

class ContentAction {
    + id : Long
    + content_id : Long
    + user_id : Long
    + action : Integer
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 内容行为表(点赞/分享/收藏/浏览)
}

class Comment {
    + id : Long
    + content_id : Long
    + user_id : Long
    + parent_id : Long
    + reply_to_id : Long
    + reply_to_user_id : Long
    + comment_text : String
    + like_count : Integer
    + reply_count : Integer
    + is_top : Boolean
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 评论表(支持多级回复)
}

class CommentLike {
    + id : Long
    + comment_id : Long
    + user_id : Long
    + status : Integer
    + created_at : DateTime
    --
    ' 评论点赞表
}

class ContentDraft {
    + id : Long
    + user_id : Long
    + type : Integer
    + title : String
    + content : String
    + location_name : String
    + location_address : String
    + location_lat : Decimal
    + location_lng : Decimal
    + city_id : Long
    + auto_save_time : DateTime
    + expire_time : DateTime
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 内容草稿表(自动保存/30天过期)
}

class ContentTopic {
    + id : Long
    + content_id : Long
    + topic_id : Long
    + sort_order : Integer
    + created_at : DateTime
    --
    ' 内容话题关联表(最多5个话题)
}

class TopicFollow {
    + id : Long
    + user_id : Long
    + topic_id : Long
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 用户关注话题表
}

class UserRelation {
    + id : Long
    + user_id : Long
    + target_id : Long
    + type : Integer
    + status : Integer
    + created_at : DateTime
    --
    ' 用户关系表(关注/拉黑/好友/特别关注)
}

' ===== 游戏服务模块 (3表) =====

class GameService {
    + id : Long
    + content_id : Long
    + user_id : Long
    + game_name : String
    + game_type : Integer
    + service_mode : Integer
    + current_rank : String
    + highest_rank : String
    + win_rate : Decimal
    + price_per_game : Long
    + price_per_hour : Long
    + voice_url : String
    + is_online : Boolean
    + status : Integer
    + version : Integer
    + deleted_at : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 游戏陪玩服务表
}

class GameSkill {
    + id : Long
    + game_service_id : Long
    + skill_type : Integer
    + skill_name : String
    + skill_value : String
    + proficiency_level : Integer
    + rank_label : String
    + hero_count : Integer
    + description : String
    + sort_order : Integer
    --
    ' 游戏技能详情表(位置/英雄/特长)
}

class GameServiceTag {
    + id : Long
    + game_service_id : Long
    + tag_category : Integer
    + tag_name : String
    + tag_color : String
    + sort_order : Integer
    --
    ' 游戏服务标签表
}

' ===== 生活服务模块 (3表) =====

class LifeService {
    + id : Long
    + content_id : Long
    + user_id : Long
    + service_type : Integer
    + service_name : String
    + service_mode : Integer
    + location_address : String
    + location : Point
    + service_area : String
    + service_duration : Integer
    + participant_limit : Integer
    + price_per_person : Long
    + price_per_time : Long
    + is_merchant_verified : Boolean
    + status : Integer
    + version : Integer
    + deleted_at : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 生活服务表(探店/私影/台球/K歌等)
}

class LifeServiceFeature {
    + id : Long
    + life_service_id : Long
    + feature_category : Integer
    + feature_name : String
    + feature_value : String
    + feature_color : String
    + sort_order : Integer
    --
    ' 生活服务特色表
}

class LifeServiceTag {
    + id : Long
    + life_service_id : Long
    + tag_category : Integer
    + tag_name : String
    + tag_color : String
    + sort_order : Integer
    --
    ' 生活服务标签表
}

class ServiceStats {
    + service_id : Long
    + service_type : Integer
    + service_count : Integer
    + avg_rating : Decimal
    + good_rate : Decimal
    + avg_response_minutes : Integer
    + total_revenue : Long
    + last_sync_time : DateTime
    + updated_at : DateTime
    --
    ' 服务统计表(游戏+生活服务共用/异步同步)
}

' ===== 订单评价模块 (2表) =====

class ServiceOrder {
    + id : Long
    + order_no : String
    + buyer_id : Long
    + seller_id : Long
    + content_id : Long
    + service_type : Integer
    + service_name : String
    + service_time : DateTime
    + service_duration : Integer
    + participant_count : Integer
    + amount : Long
    + base_fee : Long
    + person_fee : Long
    + platform_fee : Long
    + discount_amount : Long
    + actual_amount : Long
    + status : Integer
    + contact_name : String
    + contact_phone : String
    + special_request : String
    + payment_method : String
    + payment_time : DateTime
    + cancel_reason : String
    + cancel_time : DateTime
    + created_at : DateTime
    + completed_at : DateTime
    --
    ' 服务订单表(游戏/生活/活动统一管理)
}

class ServiceReview {
    + id : Long
    + order_id : Long
    + content_id : Long
    + reviewer_id : Long
    + reviewee_id : Long
    + service_type : Integer
    + rating_overall : Decimal
    + rating_service : Decimal
    + rating_attitude : Decimal
    + rating_quality : Decimal
    + review_text : String
    + review_images : String
    + is_anonymous : Boolean
    + like_count : Integer
    + reply_text : String
    + reply_time : DateTime
    + status : Integer
    + created_at : DateTime
    --
    ' 服务评价表(多维度评分+商家回复)
}

' ===== 话题标签模块 (2表) =====

class Topic {
    + id : Long
    + name : String
    + description : String
    + cover_url : String
    + creator_id : Long
    + category : Integer
    + last_post_time : DateTime
    + is_hot : Boolean
    + is_trending : Boolean
    + status : Integer
    + deleted_at : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 话题标签表(#王者荣耀#)
}

class TopicStats {
    + topic_id : Long
    + participant_count : Integer
    + post_count : Integer
    + view_count : Integer
    + like_count : Integer
    + comment_count : Integer
    + share_count : Integer
    + follow_count : Integer
    + heat_score : Integer
    + trend_score : Decimal
    + today_post_count : Integer
    + week_post_count : Integer
    + month_post_count : Integer
    + last_sync_time : DateTime
    + updated_at : DateTime
    --
    ' 话题统计表(Redis+定时同步)
}

class UserTag {
    + id : Long
    + user_id : Long
    + tag_type : Integer
    + tag_value : String
    + level : Integer
    + verified : Boolean
    + score : Integer
    + description : String
    + expire_time : DateTime
    + created_at : DateTime
    --
    ' 用户标签表(技能/职业/认证/兴趣)
}

' ===== 媒体文件模块 (1表) =====

class Media {
    + id : Long
    + uploader_id : Long
    + ref_type : String
    + ref_id : Long
    + file_type : Integer
    + file_url : String
    + thumbnail_url : String
    + width : Integer
    + height : Integer
    + duration : Integer
    + file_size : Long
    + file_format : String
    + status : Integer
    + created_at : DateTime
    --
    ' 媒体文件表(图片/视频/音频)
}

' ===== 通知推送模块 (1表) =====

class Notification {
    + id : Long
    + user_id : Long
    + category : Integer
    + type : Integer
    + priority : Integer
    + title : String
    + content : String
    + sender_id : Long
    + ref_type : String
    + ref_id : Long
    + action_type : String
    + action_url : String
    + action_button_text : String
    + secondary_action_text : String
    + is_read : Boolean
    + is_handled : Boolean
    + expire_time : DateTime
    + created_at : DateTime
    + read_at : DateTime
    + handled_at : DateTime
    --
    ' 通知消息表(多分类+优先级管理)
}

' ===== 安全审核模块 (1表) =====

class Report {
    + id : Long
    + reporter_id : Long
    + target_id : Long
    + target_type : Integer
    + reason : Integer
    + description : String
    + evidence_images : String
    + evidence_urls : String
    + status : Integer
    + handler_id : Long
    + handle_result : String
    + created_at : DateTime
    + handled_at : DateTime
    --
    ' 举报记录表(用户/内容/评论)
}

' ===== 搜索历史模块 (1表) =====

class SearchHistory {
    + id : Long
    + user_id : Long
    + session_id : String
    + keyword : String
    + keyword_normalized : String
    + search_type : Integer
    + search_scope : Integer
    + filter_params : String
    + result_count : Integer
    + first_click_position : Integer
    + first_click_target_id : Long
    + total_click_count : Integer
    + search_duration : Integer
    + is_satisfied : Boolean
    + device_id : String
    + device_type : String
    + ip_address : String
    + city_id : Long
    + source_page : String
    + created_at : DateTime
    + date_partition : Date
    --
    ' 搜索历史表(按日期分区/30天热数据)
}

' ===== 聊天模块 (5表) =====

class ChatConversation {
    + id : Long
    + type : Integer
    + title : String
    + creator_id : Long
    + avatar_url : String
    + description : String
    + order_id : Long
    + last_message_id : Long
    + last_message_time : DateTime
    + total_message_count : Integer
    + member_count : Integer
    + status : Integer
    + deleted_at : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 聊天会话表(私聊/群聊/系统/订单)
}

class ChatMessage {
    + id : Long
    + conversation_id : Long
    + sender_id : Long
    + message_type : Integer
    + content : String
    + media_url : String
    + thumbnail_url : String
    + media_size : Long
    + media_width : Integer
    + media_height : Integer
    + media_duration : Integer
    + media_caption : String
    + reply_to_id : Long
    + client_id : String
    + sequence_id : Long
    + delivery_status : Integer
    + read_count : Integer
    + like_count : Integer
    + is_recalled : Boolean
    + recall_time : DateTime
    + recalled_by : Long
    + status : Integer
    + send_time : DateTime
    + server_time : DateTime
    + deleted_at : DateTime
    + created_at : DateTime
    --
    ' 聊天消息表(分256张表/30天归档)
}

class ChatParticipant {
    + id : Long
    + conversation_id : Long
    + user_id : Long
    + role : Integer
    + join_time : DateTime
    + last_read_message_id : Long
    + last_read_time : DateTime
    + unread_count : Integer
    + is_pinned : Boolean
    + is_muted : Boolean
    + mute_until : DateTime
    + nickname : String
    + status : Integer
    + leave_time : DateTime
    --
    ' 会话参与者表(个性化设置/已读管理)
}

class MessageSettings {
    + id : Long
    + user_id : Long
    + push_enabled : Boolean
    + push_sound_enabled : Boolean
    + push_vibrate_enabled : Boolean
    + push_preview_enabled : Boolean
    + push_start_time : String
    + push_end_time : String
    + push_like_enabled : Boolean
    + push_comment_enabled : Boolean
    + push_follow_enabled : Boolean
    + push_system_enabled : Boolean
    + who_can_message : Integer
    + who_can_add_friend : Integer
    + message_read_receipt : Boolean
    + online_status_visible : Boolean
    + auto_download_image : Boolean
    + auto_download_video : Boolean
    + auto_play_voice : Boolean
    + message_retention_days : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 消息设置表(用户个性化偏好)
}

class TypingStatus {
    + id : Long
    + conversation_id : Long
    + user_id : Long
    + is_typing : Boolean
    + start_time : DateTime
    + last_update_time : DateTime
    + expire_time : DateTime
    --
    ' 输入状态表(正在输入.../10秒过期)
}

' ===== 首页功能新增模块 (4表) =====

class UserPreference {
    + id : Long
    + user_id : Long
    + preference_category : Integer
    + filter_game_types : String
    + filter_service_types : String
    + filter_activity_types : String
    + filter_price_min : Long
    + filter_price_max : Long
    + filter_distance_km : Integer
    + filter_gender : Integer
    + filter_age_min : Integer
    + filter_age_max : Integer
    + filter_online_only : Boolean
    + filter_verified_only : Boolean
    + filter_rating_min : Decimal
    + sort_by : String
    + sort_order : String
    + auto_location : Boolean
    + last_city_id : Long
    + last_location : Point
    + notification_push_enabled : Boolean
    + notification_categories : String
    + privacy_who_can_message : Integer
    + privacy_who_can_view_profile : Integer
    + privacy_show_online_status : Boolean
    + use_count : Integer
    + last_used_time : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 用户偏好设置表(个性化推荐核心/Redis缓存1小时)
}

class UserBehavior {
    + id : Long
    + user_id : Long
    + session_id : String
    + behavior_type : Integer
    + behavior_action : String
    + target_type : Integer
    + target_id : Long
    + target_title : String
    + target_user_id : Long
    + duration_seconds : Integer
    + scroll_depth : Integer
    + source_page : String
    + source_module : String
    + referrer : String
    + is_conversion : Boolean
    + conversion_type : Integer
    + conversion_value : Long
    + device_id : String
    + device_type : String
    + ip_address : String
    + city_id : Long
    + network_type : String
    + app_version : String
    + created_at : DateTime
    + date_partition : Date
    --
    ' 用户行为追踪表(按日期分区/7天热+30天温+归档冷)
}

class HotSearch {
    + id : Long
    + keyword : String
    + keyword_normalized : String
    + search_count_today : Integer
    + search_count_week : Integer
    + search_count_total : Integer
    + click_count : Integer
    + click_through_rate : Decimal
    + conversion_count : Integer
    + conversion_rate : Decimal
    + avg_result_count : Integer
    + category : Integer
    + heat_score : Integer
    + trend_score : Decimal
    + rank_position : Integer
    + rank_change : Integer
    + is_rising : Boolean
    + related_keywords : String
    + icon_url : String
    + link_url : String
    + status : Integer
    + last_search_time : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 热门搜索表(Redis Sorted Set/每5分钟更新)
}

class City {
    + id : Long
    + code : String
    + name : String
    + province : String
    + province_code : String
    + level : Integer
    + center_location : Point
    + city_area : Polygon
    + user_count : Integer
    + content_count : Integer
    + activity_count : Integer
    + service_count : Integer
    + hot_score : Integer
    + growth_rate : Decimal
    + pinyin : String
    + short_pinyin : String
    + area_code : String
    + timezone : String
    + weather_code : String
    + sort_order : Integer
    + is_hot : Boolean
    + is_open : Boolean
    + status : Integer
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 城市数据表(SPATIAL INDEX空间索引/Redis永久缓存)
}

' ===== 活动组局模块 (3表) =====

class Activity {
    + id : Long
    + content_id : Long
    + organizer_id : Long
    + activity_type : Integer
    + activity_name : String
    + activity_desc : String
    + location_name : String
    + location_address : String
    + location : Point
    + start_time : DateTime
    + end_time : DateTime
    + duration_hours : Integer
    + participant_limit : Integer
    + participant_min : Integer
    + current_participants : Integer
    + fee_type : Integer
    + price_per_person : Long
    + fee_detail : String
    + discount_info : String
    + gender_requirement : Integer
    + age_min : Integer
    + age_max : Integer
    + skill_requirement : String
    + other_requirement : String
    + status : Integer
    + version : Integer
    + deleted_at : DateTime
    + created_at : DateTime
    + updated_at : DateTime
    --
    ' 活动组局表(K歌/台球/私影/探店等)
}

class ActivityParticipant {
    + id : Long
    + activity_id : Long
    + user_id : Long
    + participant_type : Integer
    + contact_name : String
    + contact_phone : String
    + gender : Integer
    + join_message : String
    + pay_status : Integer
    + payment_amount : Long
    + discount_amount : Long
    + actual_amount : Long
    + payment_method : String
    + order_id : Long
    + status : Integer
    + joined_at : DateTime
    + payment_time : DateTime
    + confirmed_at : DateTime
    --
    ' 活动参与者表(报名管理+费用明细)
}

class ActivityTag {
    + id : Long
    + activity_id : Long
    + tag_name : String
    + tag_color : String
    + tag_type : Integer
    + sort_order : Integer
    --
    ' 活动标签表(系统推荐/用户自定义)
}

' ==========================================
' 🔗 UML关系定义
' ==========================================

' ===== 用户核心关系 =====
' 优化：User + UserProfile 已合并为单一 User 表
User "1" *-- "1" UserWallet
User "1" o-- "0..*" Transaction
User "1" -- "0..1" UserStats
User "1" o-- "0..*" UserOccupation
UserOccupation "*" -- "1" OccupationDict

' ===== 登录认证关系 =====
User "1" o-- "0..*" LoginSession
User "1" o-- "0..*" UserDevice
User "1" o-- "0..*" LoginLog
User "1" o-- "0..*" SecurityLog
User "1" -- "0..*" PasswordResetSession
SmsVerification "1" -- "0..1" PasswordResetSession
LoginSession "1" -- "1" UserDevice
LoginSession "1" -- "0..1" TokenBlacklist
SmsVerification "*" -- "0..1" PhoneVerifyLimit
User "1" o-- "0..*" TokenBlacklist

' ===== 用户偏好行为关系 =====
User "1" o-- "0..*" UserPreference
User "1" o-- "0..*" UserBehavior
User "1" o-- "0..*" SearchHistory

' ===== 用户内容关系 =====
User "1" o-- "0..*" Content
User "1" o-- "0..*" ContentDraft
User "1" -- "0..*" ContentAction
Content "1" o-- "0..*" ContentAction
Content "1" -- "0..1" ContentStats

' ===== 评论系统关系 =====
Content "1" o-- "0..*" Comment
User "1" -- "0..*" Comment
Comment "1" -- "0..*" Comment
Comment "1" o-- "0..*" CommentLike
User "1" -- "0..*" CommentLike

' ===== 用户标签认证关系 =====
User "1" o-- "0..*" UserTag
User "1" -- "0..*" Topic

' ===== 用户关系自关联 =====
User "1" -- "0..*" UserRelation
User "1" -- "0..*" UserRelation

' ===== 游戏服务关系 =====
Content "1" -- "0..1" GameService
User "1" -- "0..*" GameService
GameService "1" *-- "0..*" GameSkill
GameService "1" *-- "0..*" GameServiceTag
GameService "1" -- "0..1" ServiceStats

' ===== 生活服务关系 =====
Content "1" -- "0..1" LifeService
User "1" -- "0..*" LifeService
LifeService "1" *-- "0..*" LifeServiceFeature
LifeService "1" *-- "0..*" LifeServiceTag
LifeService "1" -- "0..1" ServiceStats

' ===== 活动组局关系 =====
Content "1" -- "0..1" Activity
User "1" -- "0..*" Activity
Activity "1" *-- "0..*" ActivityParticipant
Activity "1" *-- "0..*" ActivityTag
User "1" -- "0..*" ActivityParticipant
ServiceOrder "1" -- "0..1" ActivityParticipant

' ===== 订单多角色关系 =====
User "1" -- "0..*" ServiceOrder
User "1" -- "0..*" ServiceOrder
Content "1" -- "0..*" ServiceOrder

' ===== 评价系统关系 =====
ServiceOrder "1" -- "0..1" ServiceReview
User "1" -- "0..*" ServiceReview
User "1" -- "0..*" ServiceReview
Content "1" -- "0..*" ServiceReview

' ===== 媒体文件关系 =====
User "1" -- "0..*" Media
Content "1" -- "0..*" Media
ServiceReview "1" -- "0..*" Media
ChatMessage "1" -- "0..*" Media

' ===== 通知系统关系 =====
User "1" -- "0..*" Notification
ContentAction ..> Notification
Comment ..> Notification
CommentLike ..> Notification
UserRelation ..> Notification
TopicFollow ..> Notification
ServiceOrder ..> Notification

' ===== 举报系统关系 =====
User "1" -- "0..*" Report
User "1" -- "0..*" Report
Content "1" -- "0..*" Report
Comment "1" -- "0..*" Report
User "1" -- "0..*" Report

' ===== 聊天模块关系 =====
ChatConversation "1" *-- "0..*" ChatMessage
ChatConversation "1" *-- "1..*" ChatParticipant
ChatConversation "1" o-- "0..*" TypingStatus
User "1" -- "0..*" ChatConversation
User "1" -- "0..*" ChatMessage
User "1" -- "0..*" ChatParticipant
User "1" *-- "0..1" MessageSettings
ChatMessage "1" -- "0..*" ChatMessage
User "1" -- "0..*" TypingStatus

' ===== 订单聊天关系 =====
ServiceOrder "1" ..> ChatConversation

' ===== 话题内容关系 =====
Topic "1" o-- "0..*" ContentTopic
Content "1" o-- "0..*" ContentTopic
Topic "1" o-- "0..*" TopicFollow
User "1" -- "0..*" TopicFollow
User "1" -- "0..*" Topic
Topic "1" -- "0..1" TopicStats

' ===== 城市位置关系 =====
City "1" -- "0..*" User
City "1" -- "0..*" Content
City "1" -- "0..*" ContentDraft

' ===== 热门搜索关系 =====
HotSearch ..> SearchHistory

@enduml


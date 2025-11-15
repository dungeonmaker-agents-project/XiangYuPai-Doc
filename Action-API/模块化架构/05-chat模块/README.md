# 05-chat模块 (消息域)

## 模块概述

**模块职责**: 私信聊天、会话管理、实时通信、通知管理

这是应用的**核心交互模块**,提供用户间私信沟通和全平台通知推送功能,是用户活跃度和社交体验的关键模块。

✅ **当前状态**: 模块已完成,文档齐全

---

## 后端服务 (2个)

### ChatService (聊天服务) ✅
- **文档**: [Backend/ChatService后端服务.md](./Backend/ChatService后端服务.md)
- **职责**: 私信聊天、会话管理、消息发送接收、实时通信
- **端口**: 8005
- **数据库**: xypai_chat
- **API路径**: `/api/message/*`
- **接口数**: 10个对外API + 3个RPC接口

**核心功能**:
- 会话列表管理(查询、创建、删除、清空)
- 消息发送接收(文字、图片、语音、视频)
- 消息状态管理(已读、撤回、删除)
- 实时通信(WebSocket)
- 在线状态同步
- 媒体文件上传

**RPC调用依赖**:
- `UserService.getBatchUserInfo()` - 批量获取用户信息
- `UserService.checkBlacklist()` - 检查黑名单
- `NotificationService.getUnreadCount()` - 获取通知未读数

### NotificationService (通知服务) ✅
- **文档**: [../06-common模块/Backend/NotificationService后端服务.md](../06-common模块/Backend/NotificationService后端服务.md)
- **职责**: 全平台通知管理、推送通知
- **端口**: 8009
- **数据库**: xypai_common
- **API路径**: `/api/notification/*`
- **接口数**: 4个对外API + 6个RPC接口
- **所属**: 06-common模块(通用服务)

**核心功能**:
- 通知创建和发送(赞和收藏、评论、粉丝、系统通知)
- 通知列表查询(分类查询、分页)
- 未读数统计(4种类型+总数)
- 已读状态管理(标记已读、清除已读)
- 推送通知(WebSocket实时推送 + APNs/FCM离线推送)

**RPC调用依赖**:
- `UserService.getBatchUserInfo()` - 批量获取用户信息
- `UserService.checkFollowingBatch()` - 批量查询关注状态
- `UserService.getPushSettings()` - 获取推送设置
- `UserService.getDeviceTokens()` - 获取设备Token

---

## 前端页面 (3个) ✅

1. **[01-消息主页页面.md](./Frontend/01-消息主页页面.md)** ✅
   - 路由: `/message/main`
   - 功能: 消息主页,包含会话列表和4个通知分类Tab
   - 主要接口:
     - `GET /api/message/unread-count` - 获取未读消息数
     - `GET /api/message/conversations` - 获取会话列表
     - `DELETE /api/message/conversation/{conversationId}` - 删除会话
     - `POST /api/message/clear-all` - 清除所有消息

2. **[02-聊天页面.md](./Frontend/02-聊天页面.md)** ✅
   - 路由: `/message/chat/:conversationId`
   - 功能: 一对一私信聊天,支持文字、图片、语音、视频消息
   - 主要接口:
     - `GET /api/message/chat/{conversationId}` - 获取聊天记录
     - `POST /api/message/send` - 发送消息
     - `PUT /api/message/read/{conversationId}` - 标记消息已读
     - `POST /api/message/recall/{messageId}` - 撤回消息
     - `DELETE /api/message/{messageId}` - 删除消息
     - `POST /api/message/upload` - 上传媒体文件

3. **[03-通知页面.md](./Frontend/03-通知页面.md)** ✅
   - 路由: `/message/notification/:type`
   - 功能: 通知列表页面,包含4种通知类型(赞和收藏、评论、粉丝、系统通知)
   - 主要接口:
     - `GET /api/notification/list/{type}` - 获取通知列表
     - `PUT /api/notification/read/{type}` - 标记通知已读
     - `DELETE /api/notification/clear/{type}` - 清除已读通知
     - `GET /api/notification/unread-count` - 获取未读数
     - `POST /api/user/follow` - 关注/取消关注(粉丝通知专用,调用UserService)

---

## 核心业务流程

### 私信聊天流程

```
消息主页
  1. 显示会话列表(最近联系人)
  2. 显示未读消息数
  ↓
用户点击会话
  ↓
聊天页面
  1. 加载聊天记录(最近20条)
  2. 建立WebSocket连接
  3. 自动标记消息已读
  ↓
用户发送消息
  1. 输入内容(文字/选择媒体)
  2. 上传媒体文件(如果有)
  3. 调用发送消息API
  ↓
ChatService
  1. 验证用户权限
  2. 检查黑名单
  3. 创建/更新会话记录
  4. 创建消息记录
  5. 更新会话最后消息
  6. 通过WebSocket推送给接收者
  7. 如果接收者离线,发送离线推送通知
  ↓
接收者
  实时接收: WebSocket推送 → 立即显示新消息
  离线接收: 推送通知(APNs/FCM) → 上线后同步消息
```

### 通知流程

```
用户操作触发通知创建
(例如:点赞动态、评论、关注)
  ↓
调用方服务(ContentService/UserService)
  调用NotificationService RPC:
  createNotification({
    receiverId: 目标用户ID,
    type: 通知类型,
    senderId: 发送者ID,
    actionType: 动作类型,
    targetType: 目标类型,
    targetId: 目标ID,
    content: 通知内容
  })
  ↓
NotificationService
  1. 检查去重(24小时内同一动作)
  2. 创建通知记录
  3. 清除缓存(未读数、通知列表)
  ↓
  并行操作:
  ├── WebSocket实时推送(如果用户在线)
  │   └── 客户端收到 → 更新未读角标
  │
  └── 离线推送(如果用户离线)
      ├── iOS: APNs推送
      └── Android: FCM推送
  ↓
用户查看通知
  1. 从消息主页点击通知Tab
  2. 跳转到通知页面
  3. 加载通知列表
  4. 自动标记为已读
  5. 清除未读角标
  ↓
用户点击通知
  根据通知类型跳转:
  - 赞和收藏 → 动态详情页
  - 评论 → 动态详情页(定位到评论)
  - 粉丝 → 用户主页
  - 系统通知 → 对应功能页
```

### 消息撤回流程

```
用户长按自己的消息
  ↓
1. 弹出操作菜单:"撤回"、"删除"、"取消"
  ↓
2. 用户点击"撤回"
  ↓
3. 客户端检查时间:
   - <2分钟: 允许撤回
   - ≥2分钟: 提示"超过2分钟,无法撤回"
  ↓
4. 调用撤回消息API
   POST /api/message/recall/{messageId}
  ↓
ChatService
  1. 验证权限(只能撤回自己的消息)
  2. 验证时间(2分钟内)
  3. 更新消息isRecalled=true
  4. 通过WebSocket通知接收者
  ↓
双方客户端
  发送者: 消息替换为"你撤回了一条消息"
  接收者: 消息替换为"对方撤回了一条消息"
```

---

## 服务依赖关系

### ChatService 依赖

```
ChatService
  → UserService (RPC, 02-user模块)
    - getBatchUserInfo() - 批量获取用户信息
    - checkBlacklist() - 检查黑名单

  → NotificationService (RPC, 06-common模块)
    - getUnreadCount() - 获取通知未读数
```

### NotificationService 依赖

```
NotificationService
  → UserService (RPC, 02-user模块)
    - getBatchUserInfo() - 批量获取用户信息
    - checkFollowingBatch() - 批量查询关注状态
    - getPushSettings() - 获取推送设置
    - getDeviceTokens() - 获取设备Token
```

### 被依赖的服务

```
ChatService 被调用:
  ← UserService (获取用户会话列表、未读消息数)

NotificationService 被调用:
  ← ContentService (创建点赞/收藏/评论通知)
  ← UserService (创建关注通知)
  ← ChatService (获取通知未读数)
  ← TradeService (创建交易相关通知)
```

---

## 数据库设计

### ChatService数据库 (xypai_chat)

**主要表结构** (2张表):

#### 1. conversation (会话表)
```typescript
id, userId, otherUserId,
lastMessage, lastMessageTime, unreadCount,
deleted, deletedAt, createdAt, updatedAt
```

**索引**:
- `(userId, deleted)`
- `(userId, otherUserId, deleted)`
- `(lastMessageTime)`

#### 2. message (消息表)
```typescript
id, conversationId, senderId, receiverId,
messageType, content, mediaUrl, thumbnailUrl, duration,
status, isRecalled, recalledAt,
deleted, deletedAt, createdAt, updatedAt
```

**索引**:
- `(conversationId, deleted, createdAt)`
- `(senderId, receiverId)`
- `(status)`

**消息类型**:
- `text`: 文字消息
- `image`: 图片消息
- `voice`: 语音消息
- `video`: 视频消息

**消息状态**:
- `0`: 发送中
- `1`: 已送达
- `2`: 已读
- `3`: 失败

### NotificationService数据库 (xypai_common)

**主要表结构** (1张表):

#### notification (通知表)
```typescript
id, receiverId, type, senderId,
actionType, targetType, targetId,
targetContent, targetThumbnail,
content, title,
isRead, readAt,
deleted, deletedAt, createdAt, updatedAt
```

**索引**:
- `(receiverId, type, isRead, deleted)`
- `(receiverId, type, createdAt)`
- `(senderId)`
- `(targetType, targetId)`

**通知类型(type)**:
- `likes`: 赞和收藏通知
- `comments`: 评论通知
- `followers`: 粉丝通知
- `system`: 系统通知

**动作类型(actionType)**:
- `like`: 点赞
- `collect`: 收藏
- `comment`: 评论
- `reply`: 回复
- `follow`: 关注
- `system`: 系统通知

**目标类型(targetType)**:
- `feed`: 动态
- `comment`: 评论
- `user`: 用户

---

## 技术栈

### 后端
- **框架**: Node.js + TypeScript + Express
- **ORM**: TypeORM
- **数据库**: MySQL 8.0+
- **缓存**: Redis 7.0+ (未读数、会话列表、在线状态)
- **实时通信**: WebSocket (Socket.io)
- **推送**: APNs (iOS) + FCM (Android)
- **媒体存储**: OSS/S3

### 前端
- **框架**: React Native + Expo + TypeScript
- **状态管理**: Redux/MobX
- **实时通信**: WebSocket (Socket.io-client)
- **媒体处理**: expo-image-picker, expo-av

### 缓存策略

#### ChatService缓存

```
未读消息数:
  Key: unread:count:{userId}
  TTL: 3分钟
  更新: 新消息/标记已读时清除

会话列表:
  Key: conversation:list:{userId}:page:{page}
  TTL: 5分钟
  更新: 新消息/删除会话时清除

在线状态:
  Key: online:{userId}
  TTL: 5分钟
  更新: WebSocket心跳时刷新
```

#### NotificationService缓存

```
通知列表:
  Key: notification:list:{userId}:{type}:page:{page}
  TTL: 5分钟
  更新: 新通知/标记已读/清除通知时清除

未读数:
  Key: notification:unread:{userId}
  TTL: 3分钟
  更新: 新通知/标记已读时清除

通知去重:
  Key: notification:dup:{receiverId}:{senderId}:{actionType}:{targetId}
  TTL: 24小时
  用途: 防止重复通知
```

---

## API路径规划

### ChatService API (10个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/message/unread-count | GET | 获取未读消息数 | ✅ |
| /api/message/conversations | GET | 获取会话列表 | ✅ |
| /api/message/conversation/{conversationId} | DELETE | 删除会话 | ✅ |
| /api/message/clear-all | POST | 清除所有消息 | ✅ |
| /api/message/chat/{conversationId} | GET | 获取聊天记录 | ✅ |
| /api/message/send | POST | 发送消息 | ✅ |
| /api/message/read/{conversationId} | PUT | 标记消息已读 | ✅ |
| /api/message/recall/{messageId} | POST | 撤回消息 | ✅ |
| /api/message/{messageId} | DELETE | 删除消息 | ✅ |
| /api/message/upload | POST | 上传媒体文件 | ✅ |

### NotificationService API (4个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/notification/list/{type} | GET | 获取通知列表 | ✅ |
| /api/notification/read/{type} | PUT | 标记通知已读 | ✅ |
| /api/notification/clear/{type} | DELETE | 清除已读通知 | ✅ |
| /api/notification/unread-count | GET | 获取未读数 | ✅ |

---

## RPC接口清单

### ChatService提供 (被其他服务调用)

```typescript
/**
 * 获取用户会话列表
 */
async getUserConversations(params: {
  userId: string;
  page: number;
  pageSize: number;
}): Promise<ConversationListResult>;

/**
 * 获取用户未读消息数
 */
async getUserUnreadCount(params: {
  userId: string;
}): Promise<number>;

/**
 * 获取会话消息列表
 */
async getConversationMessages(params: {
  conversationId: string;
  page: number;
  pageSize: number;
}): Promise<MessageListResult>;
```

### NotificationService提供 (被其他服务调用)

```typescript
/**
 * 创建通知
 */
async createNotification(data: {
  receiverId: string;
  type: string;
  senderId?: string;
  actionType: string;
  targetType: string;
  targetId: string;
  targetContent?: string;
  targetThumbnail?: string;
  content?: string;
  title?: string;
}): Promise<string>;

/**
 * 查询通知列表
 */
async getNotifications(params: {
  receiverId: string;
  type: string;
  page: number;
  pageSize: number;
}): Promise<NotificationListResult>;

/**
 * 获取未读数
 */
async getUnreadCount(receiverId: string): Promise<UnreadCountResult>;

/**
 * 标记通知已读
 */
async markAsRead(params: {
  receiverId: string;
  type?: string;
  notificationIds?: string[];
}): Promise<number>;

/**
 * 清除通知
 */
async clearNotifications(params: {
  receiverId: string;
  type?: string;
  isRead?: boolean;
}): Promise<number>;

/**
 * 发送推送通知
 */
async sendPushNotification(params: {
  receiverId: string;
  title: string;
  body: string;
  data?: any;
}): Promise<boolean>;
```

---

## WebSocket事件规范

### ChatService WebSocket事件

**客户端→服务端:**
```typescript
// 认证
{
  type: 'auth',
  token: string
}

// 正在输入
{
  type: 'typing',
  conversationId: string
}
```

**服务端→客户端:**
```typescript
// 新消息
{
  type: 'new_message',
  conversationId: string,
  message: MessageData
}

// 消息已读
{
  type: 'message_read',
  conversationId: string,
  messageIds: string[]
}

// 消息撤回
{
  type: 'message_recalled',
  messageId: string,
  conversationId: string
}

// 正在输入
{
  type: 'typing',
  userId: string,
  conversationId: string
}

// 在线状态变化
{
  type: 'online_status',
  userId: string,
  isOnline: boolean
}
```

### NotificationService WebSocket事件

**服务端→客户端:**
```typescript
// 新通知
{
  type: 'new_notification',
  notification: {
    notificationId: string,
    type: string,
    actionType: string,
    content: string,
    title: string,
    createdAt: string
  }
}

// 通知已读
{
  type: 'notification_read',
  notificationType: string,
  readCount: number
}
```

---

## 测试要点

### 功能测试
- [ ] 会话列表加载正常
- [ ] 消息发送成功(文字/图片/语音/视频)
- [ ] 消息已读状态正确
- [ ] 消息撤回功能正常(2分钟内)
- [ ] 消息删除功能正常
- [ ] 通知列表加载正常(4种类型)
- [ ] 通知已读标记正常
- [ ] 通知清除功能正常
- [ ] 未读数统计准确
- [ ] WebSocket实时推送正常
- [ ] 离线推送正常(APNs/FCM)

### 边界测试
- [ ] 空会话列表显示
- [ ] 空通知列表显示
- [ ] 网络异常处理
- [ ] 超长消息验证(>500字符)
- [ ] 文件类型验证
- [ ] 文件大小验证
- [ ] 撤回超时验证(>2分钟)
- [ ] 通知去重验证
- [ ] 黑名单验证
- [ ] Token过期处理

### 性能测试
- [ ] 会话列表查询 < 100ms
- [ ] 消息列表查询 < 150ms
- [ ] 消息发送 < 200ms
- [ ] 通知列表查询 < 100ms
- [ ] 未读数查询 < 50ms
- [ ] WebSocket消息延迟 < 500ms
- [ ] 缓存命中率 > 80%
- [ ] 并发1000请求/秒稳定

### 安全测试
- [ ] 消息内容XSS防护
- [ ] 文件类型验证
- [ ] 权限验证(只能查看/删除自己的会话)
- [ ] 黑名单机制有效
- [ ] Token验证正确
- [ ] 推送权限验证

---

## 监控告警

### 关键指标
- 消息发送成功率
- 消息送达延迟(P50, P95, P99)
- WebSocket连接数
- 在线用户数
- 通知推送成功率
- 推送延迟
- 缓存命中率
- 平均响应时间

### 告警规则
1. 消息发送失败率 > 1% → P2告警
2. WebSocket连接数骤降 > 20% → P2告警
3. 推送失败率 > 5% → P2告警
4. 消息延迟 > 2秒 → P2告警
5. 缓存命中率 < 75% → P3告警
6. 响应时间 > 300ms → P2告警

---

## 完成状态

### Phase 1: 核心文档创建 ✅ 已完成
- [x] 创建 01-消息主页页面.md
- [x] 创建 02-聊天页面.md
- [x] 创建 03-通知页面.md
- [x] 创建 ChatService后端服务.md
- [x] 创建 NotificationService后端服务.md (06-common模块)

**文档统计**:
- 前端页面文档: 3个 ✅
- 后端服务文档: 2个(1个chat模块 + 1个common模块) ✅
- 总API数: 14个对外API + 9个RPC接口

### Phase 2: 功能开发 (待实施)
- [ ] 实现ChatService 10个对外API + 3个RPC接口
- [ ] 实现NotificationService 4个对外API + 6个RPC接口
- [ ] 实现WebSocket实时通信
- [ ] 集成APNs推送(iOS)
- [ ] 集成FCM推送(Android)
- [ ] 实现媒体文件上传和处理
- [ ] 配置Redis缓存策略
- [ ] 创建数据库表(3张)

### Phase 3: 测试与上线 (待实施)
- [ ] 单元测试(接口测试)
- [ ] 集成测试(RPC调用、WebSocket、推送)
- [ ] 性能测试(响应时间、并发、缓存)
- [ ] 安全测试(XSS、权限、黑名单)
- [ ] 上线验证

---

## 设计亮点

### 1. 双向会话机制
- 发送者和接收者各自维护一份会话记录
- 删除会话只影响自己,不影响对方
- 未读数独立统计,互不干扰

### 2. 实时通信
- WebSocket长连接,消息实时推送
- 心跳机制,自动检测在线状态
- 自动重连,保证连接稳定性
- 离线消息队列,上线后自动同步

### 3. 消息撤回机制
- 2分钟内可撤回
- 双端同步显示撤回提示
- 撤回记录保留,可追溯

### 4. 通知去重机制
- 24小时内同一动作只创建一次通知
- 避免通知轰炸,提升用户体验
- Redis缓存去重判断,性能优化

### 5. 多端推送
- WebSocket实时推送(在线用户)
- APNs推送(iOS离线用户)
- FCM推送(Android离线用户)
- 推送开关控制,用户自主选择

### 6. 通用通知服务
- NotificationService作为通用服务,放在06-common模块
- 所有模块复用,统一通知能力
- 4种通知类型,覆盖全平台互动场景

---

## 下一步计划

### 对接其他模块
- **UserService**: RPC接口对接(getBatchUserInfo, checkBlacklist, checkFollowingBatch, getPushSettings, getDeviceTokens)
- **ContentService**: 调用NotificationService创建点赞/收藏/评论通知
- **TradeService**: 调用NotificationService创建交易相关通知

### 功能实现
- [ ] 实现14个对外API + 9个RPC接口
- [ ] 创建3张数据库表
- [ ] 配置Redis缓存策略(6种Key设计)
- [ ] 实现WebSocket服务器
- [ ] 集成推送服务(APNs + FCM)
- [ ] 实现媒体文件上传(集成OSS)
- [ ] 实现通知去重逻辑

### 测试与上线
- [ ] 单元测试
- [ ] 集成测试
- [ ] 性能测试:
  - 消息发送 < 200ms
  - 消息列表查询 < 150ms
  - WebSocket延迟 < 500ms
  - 通知列表查询 < 100ms
  - 缓存命中率 > 80%
  - 并发1000请求/秒稳定
- [ ] 安全测试:
  - XSS攻击防护
  - 权限控制
  - 黑名单机制
  - 推送权限验证
- [ ] 上线验证

---

**⚠️ 重要提示**:
ChatService是核心交互模块,直接影响用户沟通体验。WebSocket连接必须稳定可靠,消息送达率要求>99.9%。推送通知必须及时准确,避免打扰用户。所有RPC调用必须有超时和降级策略。

**模块维护者**: 消息域团队
**最后更新**: 2025-11-14

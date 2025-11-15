# NotificationService 后端服务文档

## 服务概述

NotificationService是通用通知服务,负责处理全平台的各类通知消息,包括赞和收藏通知、评论通知、粉丝通知、系统通知等。该服务为所有模块提供统一的通知能力,被多个模块调用(内容、用户、聊天、交易等)。

**服务名称:** xypai-notification
**服务端口:** 8009
**所属模块:** 06-common模块
**数据库:** xypai_common
**技术栈:** Node.js + TypeScript + Express + MySQL + Redis

---

## 服务架构

### 核心功能

1. **通知管理**
   - 通知创建和发送
   - 通知列表查询
   - 通知分类(赞和收藏/评论/粉丝/系统)
   - 未读数统计
   - 通知排序(按时间倒序)

2. **已读管理**
   - 标记通知已读
   - 批量标记已读
   - 未读角标更新
   - 已读状态同步

3. **通知清理**
   - 清除已读通知
   - 定时清理过期通知
   - 软删除机制

4. **推送管理**
   - 实时推送(WebSocket)
   - 离线推送(APNs/FCM)
   - 推送开关控制
   - 推送模板管理

---

## API接口

### 对外API列表(4个)

| # | API路径 | 方法 | 功能 | 状态 |
|---|---------|------|------|------|
| 1 | /api/notification/list/{type} | GET | 获取通知列表 | ✅ |
| 2 | /api/notification/read/{type} | PUT | 标记通知已读 | ✅ |
| 3 | /api/notification/clear/{type} | DELETE | 清除已读通知 | ✅ |
| 4 | /api/notification/unread-count | GET | 获取未读数 | ✅ |

### RPC接口列表(6个)

| # | 方法 | 调用方 | 功能 |
|---|------|--------|------|
| 1 | createNotification() | 各模块 | 创建通知 |
| 2 | getNotifications() | 各模块 | 查询通知列表 |
| 3 | getUnreadCount() | ChatService | 获取未读数 |
| 4 | markAsRead() | 各模块 | 标记已读 |
| 5 | clearNotifications() | 各模块 | 清除通知 |
| 6 | sendPushNotification() | 各模块 | 发送推送通知 |

---

## 接口详情

### 接口1:获取通知列表
**接口:** `GET /api/notification/list/{type}`

**请求参数:**
```typescript
{
  type: string;             // 通知类型:likes/comments/followers/system (路径参数)
  page: number;             // 页码,从1开始
  pageSize: number;         // 每页数量,默认20
  lastNotificationId?: string; // 最后一条通知ID
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    type: string;           // 通知类型
    total: number;          // 通知总数
    unreadCount: number;    // 未读数
    hasMore: boolean;       // 是否有更多通知
    list: Array<{
      notificationId: string;   // 通知ID
      type: string;             // 通知类型
      senderId: string;         // 发送者ID(系统通知为null)
      senderInfo?: {            // 发送者信息
        userId: string;
        nickname: string;
        avatar: string;
        signature?: string;     // 个性签名(粉丝通知)
        isFollowing?: boolean;  // 是否已关注(粉丝通知)
      };
      actionType: string;       // 动作类型:like/collect/comment/reply/follow/system
      targetType: string;       // 目标类型:feed/comment/user
      targetId: string;         // 目标ID
      targetContent?: string;   // 目标内容预览
      targetThumbnail?: string; // 目标缩略图(动态图片)
      content?: string;         // 通知内容(评论内容/系统通知内容)
      title?: string;           // 标题(系统通知)
      isRead: boolean;          // 是否已读
      createdAt: string;        // 创建时间,ISO格式
    }>;
  }
}
```

**业务逻辑:**

1. **验证用户登录**
   ```typescript
   const userId = req.user.id;
   if (!userId) {
     throw new AuthError('请先登录');
   }
   ```

2. **验证通知类型**
   ```typescript
   const validTypes = ['likes', 'comments', 'followers', 'system'];
   if (!validTypes.includes(type)) {
     throw new ValidationError('无效的通知类型');
   }
   ```

3. **查询通知列表**
   ```typescript
   const getNotifications = async (
     userId: string,
     type: string,
     page: number,
     pageSize: number
   ) => {
     const query = notificationRepository
       .createQueryBuilder('n')
       .where('n.receiverId = :userId', { userId })
       .andWhere('n.type = :type', { type })
       .andWhere('n.deleted = 0')
       .orderBy('n.createdAt', 'DESC')
       .skip((page - 1) * pageSize)
       .take(pageSize);

     const [notifications, total] = await query.getManyAndCount();

     // 统计未读数
     const unreadCount = await notificationRepository.count({
       where: {
         receiverId: userId,
         type,
         isRead: false,
         deleted: 0
       }
     });

     // 批量获取发送者信息
     const senderIds = notifications
       .filter(n => n.senderId)
       .map(n => n.senderId);

     const senderInfos = senderIds.length > 0
       ? await userServiceClient.getBatchUserInfo(senderIds)
       : [];

     // 对于粉丝通知,查询是否已关注
     let followingStatuses: Record<string, boolean> = {};
     if (type === 'followers' && senderIds.length > 0) {
       followingStatuses = await getFollowingStatuses(userId, senderIds);
     }

     // 组装数据
     const list = notifications.map(n => {
       const senderInfo = senderInfos.find(s => s.userId === n.senderId);

       return {
         notificationId: n.id,
         type: n.type,
         senderId: n.senderId,
         senderInfo: senderInfo ? {
           userId: senderInfo.userId,
           nickname: senderInfo.nickname,
           avatar: senderInfo.avatar,
           signature: senderInfo.signature,
           isFollowing: followingStatuses[n.senderId] || false
         } : undefined,
         actionType: n.actionType,
         targetType: n.targetType,
         targetId: n.targetId,
         targetContent: n.targetContent,
         targetThumbnail: n.targetThumbnail,
         content: n.content,
         title: n.title,
         isRead: n.isRead,
         createdAt: n.createdAt.toISOString()
       };
     });

     return {
       type,
       total,
       unreadCount,
       hasMore: total > page * pageSize,
       list
     };
   };
   ```

4. **查询关注状态**
   ```typescript
   const getFollowingStatuses = async (
     userId: string,
     targetUserIds: string[]
   ): Promise<Record<string, boolean>> => {
     const statuses = await userServiceClient.checkFollowingBatch({
       userId,
       targetUserIds
     });

     return statuses;
   };
   ```

5. **Redis缓存**
   ```typescript
   const cacheKey = `notification:list:${userId}:${type}:page:${page}`;
   const cached = await redis.get(cacheKey);

   if (cached) {
     return JSON.parse(cached);
   }

   const result = await getNotifications(userId, type, page, pageSize);

   // 缓存5分钟
   await redis.setex(cacheKey, 300, JSON.stringify(result));

   return result;
   ```

**错误码:**
- 200:成功
- 400:参数错误
- 401:未登录

---

### 接口2:标记通知已读
**接口:** `PUT /api/notification/read/{type}`

**请求参数:**
```typescript
{
  type: string;             // 通知类型 (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    type: string;
    readCount: number;      // 标记为已读的通知数
  }
}
```

**业务逻辑:**

1. **验证用户登录和类型**
   ```typescript
   const userId = req.user.id;
   const validTypes = ['likes', 'comments', 'followers', 'system'];

   if (!validTypes.includes(type)) {
     throw new ValidationError('无效的通知类型');
   }
   ```

2. **批量更新为已读**
   ```typescript
   const result = await notificationRepository
     .createQueryBuilder()
     .update(Notification)
     .set({ isRead: true, readAt: new Date() })
     .where('receiverId = :userId', { userId })
     .andWhere('type = :type', { type })
     .andWhere('isRead = false')
     .andWhere('deleted = 0')
     .execute();

   const readCount = result.affected || 0;
   ```

3. **清除缓存**
   ```typescript
   // 清除通知列表缓存
   const pattern = `notification:list:${userId}:${type}:*`;
   const keys = await redis.keys(pattern);
   if (keys.length > 0) {
     await redis.del(...keys);
   }

   // 清除未读数缓存
   await redis.del(`notification:unread:${userId}`);
   ```

4. **WebSocket通知**
   ```typescript
   // 通知客户端更新未读数
   webSocketService.sendToUser(userId, {
     type: 'notification_read',
     notificationType: type,
     readCount
   });
   ```

**错误码:**
- 200:成功
- 401:未登录
- 404:通知类型不存在

---

### 接口3:清除已读通知
**接口:** `DELETE /api/notification/clear/{type}`

**请求参数:**
```typescript
{
  type: string;             // 通知类型 (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    type: string;
    clearCount: number;     // 清除的通知数
  }
}
```

**业务逻辑:**

1. **验证参数**
   ```typescript
   const userId = req.user.id;
   const validTypes = ['likes', 'comments', 'followers', 'system'];

   if (!validTypes.includes(type)) {
     throw new ValidationError('无效的通知类型');
   }
   ```

2. **软删除已读通知**
   ```typescript
   const result = await notificationRepository
     .createQueryBuilder()
     .update(Notification)
     .set({
       deleted: 1,
       deletedAt: new Date()
     })
     .where('receiverId = :userId', { userId })
     .andWhere('type = :type', { type })
     .andWhere('isRead = true')
     .andWhere('deleted = 0')
     .execute();

   const clearCount = result.affected || 0;
   ```

3. **清除缓存**
   ```typescript
   // 清除通知列表缓存
   const pattern = `notification:list:${userId}:${type}:*`;
   const keys = await redis.keys(pattern);
   if (keys.length > 0) {
     await redis.del(...keys);
   }
   ```

**错误码:**
- 200:成功
- 401:未登录

---

### 接口4:获取未读数
**接口:** `GET /api/notification/unread-count`

**请求参数:**
```typescript
// 无需参数,从token中获取用户ID
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    likes: number;          // 赞和收藏未读数
    comments: number;       // 评论未读数
    followers: number;      // 粉丝未读数
    system: number;         // 系统通知未读数
    total: number;          // 总未读数
  }
}
```

**业务逻辑:**

1. **验证用户登录**
   ```typescript
   const userId = req.user.id;
   ```

2. **统计未读数**
   ```typescript
   const getUnreadCount = async (userId: string) => {
     const types = ['likes', 'comments', 'followers', 'system'];
     const counts: Record<string, number> = {};

     // 并行查询各类型未读数
     const promises = types.map(async (type) => {
       const count = await notificationRepository.count({
         where: {
           receiverId: userId,
           type,
           isRead: false,
           deleted: 0
         }
       });
       counts[type] = count;
     });

     await Promise.all(promises);

     const total = Object.values(counts).reduce((sum, count) => sum + count, 0);

     return {
       likes: counts.likes || 0,
       comments: counts.comments || 0,
       followers: counts.followers || 0,
       system: counts.system || 0,
       total
     };
   };
   ```

3. **Redis缓存**
   ```typescript
   const cacheKey = `notification:unread:${userId}`;
   const cached = await redis.get(cacheKey);

   if (cached) {
     return JSON.parse(cached);
   }

   const unreadCount = await getUnreadCount(userId);

   // 缓存3分钟
   await redis.setex(cacheKey, 180, JSON.stringify(unreadCount));

   return unreadCount;
   ```

**错误码:**
- 200:成功
- 401:未登录

---

## 数据模型

### Notification (通知表)

```typescript
@Entity('notification')
class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  receiverId: string;       // 接收者ID

  @Column({ length: 20 })
  type: string;             // 通知类型:likes/comments/followers/system

  @Column({ nullable: true })
  senderId: string;         // 发送者ID(系统通知为null)

  @Column({ length: 50 })
  actionType: string;       // 动作类型:like/collect/comment/reply/follow/system

  @Column({ length: 20 })
  targetType: string;       // 目标类型:feed/comment/user

  @Column()
  targetId: string;         // 目标ID

  @Column({ type: 'text', nullable: true })
  targetContent: string;    // 目标内容预览

  @Column({ nullable: true })
  targetThumbnail: string;  // 目标缩略图URL

  @Column({ type: 'text', nullable: true })
  content: string;          // 通知内容(评论内容/系统通知内容)

  @Column({ nullable: true })
  title: string;            // 标题(系统通知)

  @Column({ type: 'tinyint', default: 0 })
  isRead: boolean;          // 是否已读

  @Column({ type: 'timestamp', nullable: true })
  readAt: Date;             // 阅读时间

  @Column({ type: 'tinyint', default: 0 })
  deleted: number;          // 是否已删除

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;          // 删除时间

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['receiverId', 'type', 'isRead', 'deleted'])
  @Index(['receiverId', 'type', 'createdAt'])
  @Index(['senderId'])
  @Index(['targetType', 'targetId'])
}
```

---

## RPC接口实现

### NotificationService RPC接口

提供给其他服务调用的RPC方法:

```typescript
class NotificationService {
  /**
   * 创建通知
   * @param data 通知数据
   * @return 通知ID
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
  }): Promise<string> {
    // 检查是否已存在相同通知(去重)
    const existing = await this.checkDuplicate(data);
    if (existing) {
      return existing.id;
    }

    // 创建通知记录
    const notification = new Notification();
    notification.id = generateUUID();
    notification.receiverId = data.receiverId;
    notification.type = data.type;
    notification.senderId = data.senderId;
    notification.actionType = data.actionType;
    notification.targetType = data.targetType;
    notification.targetId = data.targetId;
    notification.targetContent = data.targetContent;
    notification.targetThumbnail = data.targetThumbnail;
    notification.content = data.content;
    notification.title = data.title;
    notification.isRead = false;

    await notificationRepository.save(notification);

    // 清除缓存
    await this.clearCache(data.receiverId, data.type);

    // WebSocket推送
    await this.pushNotification(data.receiverId, notification);

    // 离线推送
    const isOnline = await redis.get(`online:${data.receiverId}`);
    if (!isOnline) {
      await this.sendOfflinePush(data.receiverId, notification);
    }

    return notification.id;
  }

  /**
   * 查询通知列表
   * @param params 查询参数
   * @return 通知列表
   */
  async getNotifications(params: {
    receiverId: string;
    type: string;
    page: number;
    pageSize: number;
  }): Promise<NotificationListResult> {
    const { receiverId, type, page, pageSize } = params;

    const query = notificationRepository
      .createQueryBuilder('n')
      .where('n.receiverId = :receiverId', { receiverId })
      .andWhere('n.type = :type', { type })
      .andWhere('n.deleted = 0')
      .orderBy('n.createdAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize);

    const [notifications, total] = await query.getManyAndCount();

    return {
      list: notifications,
      total,
      hasMore: total > page * pageSize
    };
  }

  /**
   * 获取未读数
   * @param receiverId 接收者ID
   * @return 未读数统计
   */
  async getUnreadCount(receiverId: string): Promise<UnreadCountResult> {
    const types = ['likes', 'comments', 'followers', 'system'];
    const counts: Record<string, number> = {};

    for (const type of types) {
      const count = await notificationRepository.count({
        where: {
          receiverId,
          type,
          isRead: false,
          deleted: 0
        }
      });
      counts[type] = count;
    }

    const total = Object.values(counts).reduce((sum, count) => sum + count, 0);

    return {
      likes: counts.likes || 0,
      comments: counts.comments || 0,
      followers: counts.followers || 0,
      system: counts.system || 0,
      total
    };
  }

  /**
   * 标记通知已读
   * @param params 参数
   * @return 标记数量
   */
  async markAsRead(params: {
    receiverId: string;
    type?: string;
    notificationIds?: string[];
  }): Promise<number> {
    const { receiverId, type, notificationIds } = params;

    const query = notificationRepository
      .createQueryBuilder()
      .update(Notification)
      .set({ isRead: true, readAt: new Date() })
      .where('receiverId = :receiverId', { receiverId })
      .andWhere('isRead = false')
      .andWhere('deleted = 0');

    if (type) {
      query.andWhere('type = :type', { type });
    }

    if (notificationIds && notificationIds.length > 0) {
      query.andWhere('id IN (:...notificationIds)', { notificationIds });
    }

    const result = await query.execute();

    // 清除缓存
    await this.clearCache(receiverId, type);

    return result.affected || 0;
  }

  /**
   * 清除通知
   * @param params 参数
   * @return 清除数量
   */
  async clearNotifications(params: {
    receiverId: string;
    type?: string;
    isRead?: boolean;
  }): Promise<number> {
    const { receiverId, type, isRead } = params;

    const query = notificationRepository
      .createQueryBuilder()
      .update(Notification)
      .set({ deleted: 1, deletedAt: new Date() })
      .where('receiverId = :receiverId', { receiverId })
      .andWhere('deleted = 0');

    if (type) {
      query.andWhere('type = :type', { type });
    }

    if (isRead !== undefined) {
      query.andWhere('isRead = :isRead', { isRead });
    }

    const result = await query.execute();

    // 清除缓存
    await this.clearCache(receiverId, type);

    return result.affected || 0;
  }

  /**
   * 发送推送通知
   * @param params 推送参数
   * @return 是否成功
   */
  async sendPushNotification(params: {
    receiverId: string;
    title: string;
    body: string;
    data?: any;
  }): Promise<boolean> {
    const { receiverId, title, body, data } = params;

    // 检查用户推送设置
    const settings = await this.getUserPushSettings(receiverId);
    if (!settings.enabled) {
      return false;
    }

    // 获取设备Token
    const deviceTokens = await this.getDeviceTokens(receiverId);
    if (deviceTokens.length === 0) {
      return false;
    }

    // 发送推送
    const promises = deviceTokens.map(async (token) => {
      if (token.platform === 'ios') {
        return await this.sendAPNs(token.token, title, body, data);
      } else if (token.platform === 'android') {
        return await this.sendFCM(token.token, title, body, data);
      }
    });

    const results = await Promise.all(promises);
    return results.some(r => r === true);
  }

  // 私有方法

  /**
   * 检查重复通知
   */
  private async checkDuplicate(data: any): Promise<Notification | null> {
    // 同一用户对同一目标的同一动作,24小时内只创建一次通知
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const existing = await notificationRepository.findOne({
      where: {
        receiverId: data.receiverId,
        senderId: data.senderId,
        actionType: data.actionType,
        targetType: data.targetType,
        targetId: data.targetId,
        deleted: 0,
        createdAt: MoreThan(oneDayAgo)
      }
    });

    return existing;
  }

  /**
   * 清除缓存
   */
  private async clearCache(receiverId: string, type?: string) {
    // 清除通知列表缓存
    if (type) {
      const pattern = `notification:list:${receiverId}:${type}:*`;
      const keys = await redis.keys(pattern);
      if (keys.length > 0) {
        await redis.del(...keys);
      }
    }

    // 清除未读数缓存
    await redis.del(`notification:unread:${receiverId}`);
  }

  /**
   * WebSocket推送
   */
  private async pushNotification(receiverId: string, notification: Notification) {
    webSocketService.sendToUser(receiverId, {
      type: 'new_notification',
      notification: {
        notificationId: notification.id,
        type: notification.type,
        actionType: notification.actionType,
        content: notification.content,
        title: notification.title,
        createdAt: notification.createdAt.toISOString()
      }
    });
  }

  /**
   * 离线推送
   */
  private async sendOfflinePush(receiverId: string, notification: Notification) {
    let title = '';
    let body = '';

    switch (notification.type) {
      case 'likes':
        title = '新的赞和收藏';
        body = notification.content || '有人赞了你的动态';
        break;
      case 'comments':
        title = '新的评论';
        body = notification.content || '有人评论了你的动态';
        break;
      case 'followers':
        title = '新的粉丝';
        body = '有人关注了你';
        break;
      case 'system':
        title = notification.title || '系统通知';
        body = notification.content || '';
        break;
    }

    await this.sendPushNotification({
      receiverId,
      title,
      body,
      data: {
        notificationId: notification.id,
        type: notification.type
      }
    });
  }

  /**
   * 获取用户推送设置
   */
  private async getUserPushSettings(userId: string): Promise<PushSettings> {
    // 调用UserService获取用户推送设置
    return await userServiceClient.getPushSettings(userId);
  }

  /**
   * 获取设备Token
   */
  private async getDeviceTokens(userId: string): Promise<DeviceToken[]> {
    // 调用UserService获取用户设备Token
    return await userServiceClient.getDeviceTokens(userId);
  }

  /**
   * 发送APNs推送(iOS)
   */
  private async sendAPNs(
    token: string,
    title: string,
    body: string,
    data?: any
  ): Promise<boolean> {
    // 集成APNs推送
    try {
      // Implementation...
      return true;
    } catch (error) {
      logger.error('APNs push failed', { error, token });
      return false;
    }
  }

  /**
   * 发送FCM推送(Android)
   */
  private async sendFCM(
    token: string,
    title: string,
    body: string,
    data?: any
  ): Promise<boolean> {
    // 集成FCM推送
    try {
      // Implementation...
      return true;
    } catch (error) {
      logger.error('FCM push failed', { error, token });
      return false;
    }
  }
}
```

**其他服务调用示例:**
```typescript
// 在ContentService中调用
import { NotificationServiceClient } from '@/rpc/NotificationServiceClient';

const notificationClient = new NotificationServiceClient();

// 创建点赞通知
await notificationClient.createNotification({
  receiverId: feedAuthorId,
  type: 'likes',
  senderId: userId,
  actionType: 'like',
  targetType: 'feed',
  targetId: feedId,
  targetContent: feedContent.substring(0, 50),
  targetThumbnail: feedCoverImage
});

// 创建评论通知
await notificationClient.createNotification({
  receiverId: feedAuthorId,
  type: 'comments',
  senderId: userId,
  actionType: 'comment',
  targetType: 'feed',
  targetId: feedId,
  targetContent: feedContent.substring(0, 50),
  content: commentContent
});

// 创建关注通知
await notificationClient.createNotification({
  receiverId: targetUserId,
  type: 'followers',
  senderId: userId,
  actionType: 'follow',
  targetType: 'user',
  targetId: userId
});

// 创建系统通知
await notificationClient.createNotification({
  receiverId: userId,
  type: 'system',
  actionType: 'system',
  targetType: 'user',
  targetId: userId,
  title: '系统公告',
  content: '欢迎使用享遇派!'
});
```

---

## 通知触发场景

### 1. 赞和收藏通知(type=likes)

**触发场景:**
- 用户点赞动态 → 通知动态作者
- 用户收藏动态 → 通知动态作者

**通知内容:**
```typescript
{
  receiverId: feedAuthorId,
  type: 'likes',
  senderId: userId,
  actionType: 'like' | 'collect',
  targetType: 'feed',
  targetId: feedId,
  targetContent: feedContent.substring(0, 50),
  targetThumbnail: feedCoverImage
}
```

### 2. 评论通知(type=comments)

**触发场景:**
- 用户评论动态 → 通知动态作者
- 用户回复评论 → 通知被回复的用户

**通知内容:**
```typescript
{
  receiverId: feedAuthorId | commentAuthorId,
  type: 'comments',
  senderId: userId,
  actionType: 'comment' | 'reply',
  targetType: 'feed' | 'comment',
  targetId: feedId | commentId,
  targetContent: feedContent | commentContent,
  content: newCommentContent
}
```

### 3. 粉丝通知(type=followers)

**触发场景:**
- 用户关注另一用户 → 通知被关注的用户

**通知内容:**
```typescript
{
  receiverId: targetUserId,
  type: 'followers',
  senderId: userId,
  actionType: 'follow',
  targetType: 'user',
  targetId: userId
}
```

### 4. 系统通知(type=system)

**触发场景:**
- 系统公告
- 活动通知
- 安全提醒
- 违规警告

**通知内容:**
```typescript
{
  receiverId: userId,
  type: 'system',
  senderId: null,
  actionType: 'system',
  targetType: 'user',
  targetId: userId,
  title: '系统公告',
  content: '通知内容...'
}
```

---

## 性能优化

### 1. 去重机制

```typescript
// 同一用户对同一目标的同一动作,24小时内只创建一次通知
const checkDuplicate = async (data: NotificationData): Promise<boolean> => {
  const cacheKey = `notification:dup:${data.receiverId}:${data.senderId}:${data.actionType}:${data.targetId}`;
  const exists = await redis.exists(cacheKey);

  if (exists) {
    return true; // 重复
  }

  // 设置24小时过期
  await redis.setex(cacheKey, 86400, '1');
  return false;
};
```

### 2. 批量创建通知

```typescript
// 批量创建通知(例如:动态被多人点赞)
const createBatchNotifications = async (notifications: NotificationData[]) => {
  // 去重
  const uniqueNotifications = await filterDuplicates(notifications);

  // 批量插入
  await notificationRepository.insert(uniqueNotifications);

  // 批量推送
  const pushPromises = uniqueNotifications.map(n =>
    pushNotification(n.receiverId, n)
  );

  await Promise.all(pushPromises);
};
```

### 3. 未读数计数器

```typescript
// 使用Redis计数器优化未读数查询
const incrementUnreadCount = async (receiverId: string, type: string) => {
  const key = `notification:unread:${receiverId}`;
  await redis.hincrby(key, type, 1);
  await redis.hincrby(key, 'total', 1);
  await redis.expire(key, 180); // 3分钟过期
};

const decrementUnreadCount = async (receiverId: string, type: string, count: number) => {
  const key = `notification:unread:${receiverId}`;
  await redis.hincrby(key, type, -count);
  await redis.hincrby(key, 'total', -count);
};
```

### 4. 定时清理过期通知

```typescript
// 定时清理30天前的已读通知
const cleanupOldNotifications = async () => {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

  await notificationRepository
    .createQueryBuilder()
    .update(Notification)
    .set({ deleted: 1, deletedAt: new Date() })
    .where('isRead = true')
    .andWhere('createdAt < :date', { date: thirtyDaysAgo })
    .andWhere('deleted = 0')
    .execute();
};

// 每天凌晨3点执行
cron.schedule('0 3 * * *', cleanupOldNotifications);
```

---

## 监控与日志

### 监控指标

- 通知创建数/小时
- 通知推送成功率
- 推送延迟(P50, P95, P99)
- 未读通知数(分类统计)
- Redis缓存命中率
- 平均响应时间

### 日志记录

```typescript
logger.info('Notification created', {
  notificationId: notification.id,
  receiverId: notification.receiverId,
  type: notification.type,
  actionType: notification.actionType
});

logger.info('Push notification sent', {
  receiverId,
  platform: 'ios',
  success: true
});

logger.warn('Push notification failed', {
  receiverId,
  platform: 'android',
  error: error.message
});
```

---

## 测试用例

### 单元测试
- [ ] 通知列表查询成功
- [ ] 未读数统计正确
- [ ] 标记已读成功
- [ ] 清除通知成功
- [ ] 通知去重正常
- [ ] 推送通知成功

### 集成测试
- [ ] RPC调用成功
- [ ] WebSocket推送成功
- [ ] APNs推送成功(iOS)
- [ ] FCM推送成功(Android)
- [ ] 缓存更新正确

### 性能测试
- [ ] 通知列表查询<100ms
- [ ] 未读数查询<50ms
- [ ] 批量创建通知<200ms
- [ ] 并发1000请求/秒稳定
- [ ] 缓存命中率>80%

---

## 配置参数

### 环境变量

```bash
# 服务配置
PORT=8009
NODE_ENV=production

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=xypai_common
DB_USER=root
DB_PASSWORD=password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# APNs配置(iOS推送)
APNS_KEY_ID=your_key_id
APNS_TEAM_ID=your_team_id
APNS_TOPIC=com.xypai.app
APNS_KEY_PATH=/path/to/key.p8
APNS_PRODUCTION=true

# FCM配置(Android推送)
FCM_SERVER_KEY=your_server_key
FCM_PROJECT_ID=your_project_id

# 通知配置
NOTIFICATION_DEDUPE_HOURS=24    # 去重时间窗口(小时)
NOTIFICATION_CLEANUP_DAYS=30    # 清理已读通知天数
NOTIFICATION_PAGE_SIZE=20       # 默认分页大小

# 缓存配置
CACHE_TTL_NOTIFICATION_LIST=300 # 通知列表缓存时长(秒)
CACHE_TTL_UNREAD_COUNT=180      # 未读数缓存时长(秒)
```

---

## 部署说明

### Docker部署

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 8009

CMD ["npm", "start"]
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2025-01-XX | 初始版本 |
| 1.1.0 | 待定 | 增加富文本通知 |
| 1.2.0 | 待定 | 增加通知模板 |

---

**文档版本:** v1.0
**创建日期:** 2025-11-14
**所属模块:** 06-common模块
**维护团队:** 基础服务团队

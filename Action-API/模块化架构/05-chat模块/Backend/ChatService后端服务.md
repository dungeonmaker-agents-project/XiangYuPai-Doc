# ChatService 后端服务文档

## 服务概述

ChatService是聊天消息服务,负责处理私信对话、会话管理、消息发送接收、实时通信等功能。该服务为用户提供一对一私信功能,支持文字、图片、语音、视频等多种消息类型。

**服务名称:** xypai-chat
**服务端口:** 8005
**所属模块:** 05-chat模块
**数据库:** xypai_chat
**技术栈:** Node.js + TypeScript + Express + MySQL + Redis + WebSocket

---

## 服务架构

### 核心功能

1. **会话管理**
   - 会话列表查询
   - 会话创建和删除
   - 未读消息统计
   - 会话排序(按最后消息时间)

2. **消息管理**
   - 消息发送(文字、图片、语音、视频)
   - 消息接收和存储
   - 消息已读状态
   - 消息撤回(2分钟内)
   - 消息删除(软删除)
   - 消息历史记录

3. **实时通信**
   - WebSocket连接管理
   - 实时消息推送
   - 在线状态同步
   - 输入状态提示
   - 消息已读回执

4. **媒体处理**
   - 图片上传和压缩
   - 语音录制上传
   - 视频上传和封面生成
   - CDN分发

---

## API接口

### 对外API列表(10个)

| # | API路径 | 方法 | 功能 | 状态 |
|---|---------|------|------|------|
| 1 | /api/message/unread-count | GET | 获取未读消息数 | ✅ |
| 2 | /api/message/conversations | GET | 获取会话列表 | ✅ |
| 3 | /api/message/conversation/{conversationId} | DELETE | 删除会话 | ✅ |
| 4 | /api/message/clear-all | POST | 清除所有消息 | ✅ |
| 5 | /api/message/chat/{conversationId} | GET | 获取聊天记录 | ✅ |
| 6 | /api/message/send | POST | 发送消息 | ✅ |
| 7 | /api/message/read/{conversationId} | PUT | 标记消息已读 | ✅ |
| 8 | /api/message/recall/{messageId} | POST | 撤回消息 | ✅ |
| 9 | /api/message/{messageId} | DELETE | 删除消息 | ✅ |
| 10 | /api/message/upload | POST | 上传媒体文件 | ✅ |

### RPC接口列表(3个)

| # | 方法 | 调用方 | 功能 |
|---|------|--------|------|
| 1 | getUserConversations() | UserService | 获取用户会话列表 |
| 2 | getUserUnreadCount() | UserService | 获取用户未读消息数 |
| 3 | getConversationMessages() | UserService | 获取会话消息列表 |

---

## 接口详情

### 接口1:获取未读消息数
**接口:** `GET /api/message/unread-count`

**请求参数:**
```typescript
// 无需参数,从token中获取用户ID
```

**响应数据:**
```typescript
{
  code: number;           // 200=成功
  message: string;        // 提示信息
  data: {
    likes: number;        // 赞和收藏未读数
    comments: number;     // 评论未读数
    followers: number;    // 粉丝未读数
    system: number;       // 系统通知未读数
    total: number;        // 总未读数
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

2. **查询各类未读数**
   ```typescript
   const getUnreadCount = async (userId: string) => {
     // 查询会话未读消息数
     const conversationUnread = await conversationRepository
       .createQueryBuilder('c')
       .select('SUM(c.unreadCount)', 'total')
       .where('c.userId = :userId', { userId })
       .andWhere('c.deleted = 0')
       .getRawOne();

     // 调用NotificationService RPC获取通知未读数
     const notificationUnread = await notificationServiceClient.getUnreadCount(userId);

     return {
       likes: notificationUnread.likes,
       comments: notificationUnread.comments,
       followers: notificationUnread.followers,
       system: notificationUnread.system,
       total: conversationUnread.total + notificationUnread.total
     };
   };
   ```

3. **Redis缓存**
   ```typescript
   const cacheKey = `unread:count:${userId}`;
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

### 接口2:获取会话列表
**接口:** `GET /api/message/conversations`

**请求参数:**
```typescript
{
  page: number;           // 页码,从1开始
  pageSize: number;       // 每页数量,默认20
  lastMessageId?: string; // 最后一条消息ID,用于分页
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    total: number;        // 会话总数
    hasMore: boolean;     // 是否有更多数据
    list: Array<{
      conversationId: string;   // 会话ID
      userId: string;           // 对方用户ID
      nickname: string;         // 对方昵称
      avatar: string;           // 对方头像URL
      lastMessage: string;      // 最后一条消息内容
      lastMessageTime: string;  // 最后消息时间,ISO格式
      unreadCount: number;      // 未读消息数
      isOnline: boolean;        // 对方是否在线
    }>;
  }
}
```

**业务逻辑:**

1. **参数验证**
   ```typescript
   const validateParams = (page: number, pageSize: number) => {
     if (page < 1) throw new ValidationError('页码必须大于等于1');
     if (pageSize < 10 || pageSize > 50) {
       throw new ValidationError('每页数量必须在10-50之间');
     }
   };
   ```

2. **查询会话列表**
   ```typescript
   const getConversations = async (userId: string, page: number, pageSize: number) => {
     const query = conversationRepository
       .createQueryBuilder('c')
       .where('c.userId = :userId', { userId })
       .andWhere('c.deleted = 0')
       .orderBy('c.lastMessageTime', 'DESC')
       .skip((page - 1) * pageSize)
       .take(pageSize);

     const [conversations, total] = await query.getManyAndCount();

     // 批量获取对方用户信息
     const userIds = conversations.map(c => c.otherUserId);
     const userInfos = await userServiceClient.getBatchUserInfo(userIds);

     // 批量查询在线状态
     const onlineStatuses = await getOnlineStatuses(userIds);

     // 组装数据
     const list = conversations.map(c => {
       const userInfo = userInfos.find(u => u.userId === c.otherUserId);
       const isOnline = onlineStatuses[c.otherUserId] || false;

       return {
         conversationId: c.id,
         userId: c.otherUserId,
         nickname: userInfo?.nickname || '',
         avatar: userInfo?.avatar || '',
         lastMessage: c.lastMessage,
         lastMessageTime: c.lastMessageTime.toISOString(),
         unreadCount: c.unreadCount,
         isOnline
       };
     });

     return {
       total,
       hasMore: total > page * pageSize,
       list
     };
   };
   ```

3. **在线状态查询**
   ```typescript
   const getOnlineStatuses = async (userIds: string[]) => {
     const pipeline = redis.pipeline();
     userIds.forEach(userId => {
       pipeline.get(`online:${userId}`);
     });

     const results = await pipeline.exec();
     const statuses: Record<string, boolean> = {};

     userIds.forEach((userId, index) => {
       statuses[userId] = results[index][1] === '1';
     });

     return statuses;
   };
   ```

**错误码:**
- 200:成功
- 400:参数错误
- 401:未登录

---

### 接口3:删除会话
**接口:** `DELETE /api/message/conversation/{conversationId}`

**请求参数:**
```typescript
{
  conversationId: string; // 会话ID (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: null
}
```

**业务逻辑:**

1. **验证会话权限**
   ```typescript
   const conversation = await conversationRepository.findOne({
     where: { id: conversationId, userId }
   });

   if (!conversation) {
     throw new NotFoundError('会话不存在');
   }
   ```

2. **软删除会话**
   ```typescript
   conversation.deleted = 1;
   conversation.deletedAt = new Date();
   await conversationRepository.save(conversation);
   ```

3. **清除缓存**
   ```typescript
   await redis.del(`conversation:${conversationId}`);
   await redis.del(`unread:count:${userId}`);
   ```

**错误码:**
- 200:成功
- 403:无权限访问该会话
- 404:会话不存在

---

### 接口4:清除所有消息
**接口:** `POST /api/message/clear-all`

**请求参数:**
```typescript
// 无需参数
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: null
}
```

**业务逻辑:**

1. **批量软删除会话**
   ```typescript
   await conversationRepository
     .createQueryBuilder()
     .update(Conversation)
     .set({
       deleted: 1,
       deletedAt: new Date()
     })
     .where('userId = :userId', { userId })
     .andWhere('deleted = 0')
     .execute();
   ```

2. **清除所有未读标记**
   ```typescript
   await conversationRepository
     .createQueryBuilder()
     .update(Conversation)
     .set({ unreadCount: 0 })
     .where('userId = :userId', { userId })
     .execute();
   ```

3. **清除缓存**
   ```typescript
   await redis.del(`unread:count:${userId}`);
   ```

**错误码:**
- 200:成功
- 401:未登录
- 500:操作失败

---

### 接口5:获取聊天记录
**接口:** `GET /api/message/chat/{conversationId}`

**请求参数:**
```typescript
{
  conversationId: string;   // 会话ID (路径参数)
  page: number;             // 页码
  pageSize: number;         // 每页数量
  lastMessageId?: string;   // 最后一条消息ID
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    conversationId: string;
    userId: string;
    userInfo: {
      userId: string;
      nickname: string;
      avatar: string;
      isOnline: boolean;
    };
    messages: Array<{
      messageId: string;
      conversationId: string;
      senderId: string;
      receiverId: string;
      messageType: string;      // text/image/voice/video
      content: string;
      mediaUrl?: string;
      thumbnailUrl?: string;
      duration?: number;        // 秒
      status: number;           // 0=发送中,1=已送达,2=已读,3=失败
      isRecalled: boolean;
      createdAt: string;
    }>;
    total: number;
    hasMore: boolean;
  }
}
```

**业务逻辑:**

1. **验证会话权限**
   ```typescript
   const conversation = await conversationRepository.findOne({
     where: {
       id: conversationId,
       userId: In([userId, otherUserId])
     }
   });

   if (!conversation) {
     throw new ForbiddenError('无权限访问该会话');
   }
   ```

2. **查询消息列表**
   ```typescript
   const query = messageRepository
     .createQueryBuilder('m')
     .where('m.conversationId = :conversationId', { conversationId })
     .andWhere('m.deleted = 0')
     .orderBy('m.createdAt', 'DESC')
     .skip((page - 1) * pageSize)
     .take(pageSize);

   const [messages, total] = await query.getManyAndCount();
   ```

3. **自动标记已读**
   ```typescript
   // 标记对方发送的消息为已读
   await messageRepository
     .createQueryBuilder()
     .update(Message)
     .set({ status: 2 })
     .where('conversationId = :conversationId', { conversationId })
     .andWhere('receiverId = :userId', { userId })
     .andWhere('status = 1')
     .execute();

   // 更新会话未读数
   await conversationRepository
     .createQueryBuilder()
     .update(Conversation)
     .set({ unreadCount: 0 })
     .where('id = :conversationId', { conversationId })
     .andWhere('userId = :userId', { userId })
     .execute();
   ```

4. **通过WebSocket发送已读回执**
   ```typescript
   const otherUserId = conversation.otherUserId;
   webSocketService.sendToUser(otherUserId, {
     type: 'message_read',
     conversationId,
     messageIds: messages.filter(m => m.senderId === otherUserId).map(m => m.id)
   });
   ```

**错误码:**
- 200:成功
- 400:参数错误
- 401:未登录
- 403:无权限
- 404:会话不存在

---

### 接口6:发送消息
**接口:** `POST /api/message/send`

**请求参数:**
```typescript
{
  conversationId: string;   // 会话ID
  receiverId: string;       // 接收者ID
  messageType: string;      // text/image/voice/video
  content?: string;         // 消息内容(文字消息)
  mediaUrl?: string;        // 媒体URL
  thumbnailUrl?: string;    // 缩略图URL(视频)
  duration?: number;        // 时长(语音/视频)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    messageId: string;
    conversationId: string;
    senderId: string;
    receiverId: string;
    messageType: string;
    content: string;
    mediaUrl?: string;
    thumbnailUrl?: string;
    duration?: number;
    status: number;           // 1=已送达
    createdAt: string;
  }
}
```

**业务逻辑:**

1. **参数验证**
   ```typescript
   const validateMessage = (data: MessageData) => {
     switch (data.messageType) {
       case 'text':
         if (!data.content || data.content.length > 500) {
           throw new ValidationError('文字消息内容必填,不超过500字符');
         }
         break;
       case 'image':
         if (!data.mediaUrl) {
           throw new ValidationError('图片消息mediaUrl必填');
         }
         break;
       case 'voice':
         if (!data.mediaUrl || !data.duration) {
           throw new ValidationError('语音消息mediaUrl和duration必填');
         }
         if (data.duration < 1 || data.duration > 60) {
           throw new ValidationError('语音时长必须在1-60秒之间');
         }
         break;
       case 'video':
         if (!data.mediaUrl || !data.thumbnailUrl || !data.duration) {
           throw new ValidationError('视频消息mediaUrl、thumbnailUrl和duration必填');
         }
         if (data.duration < 1 || data.duration > 60) {
           throw new ValidationError('视频时长必须在1-60秒之间');
         }
         break;
     }
   };
   ```

2. **检查黑名单**
   ```typescript
   const isBlocked = await userServiceClient.checkBlacklist(receiverId, userId);
   if (isBlocked) {
     throw new ForbiddenError('对方已拉黑你');
   }
   ```

3. **创建或获取会话**
   ```typescript
   let conversation = await conversationRepository.findOne({
     where: {
       userId,
       otherUserId: receiverId,
       deleted: 0
     }
   });

   if (!conversation) {
     // 创建新会话(双向)
     conversation = new Conversation();
     conversation.id = generateUUID();
     conversation.userId = userId;
     conversation.otherUserId = receiverId;
     conversation.lastMessage = '';
     conversation.lastMessageTime = new Date();
     conversation.unreadCount = 0;
     await conversationRepository.save(conversation);

     // 为对方也创建会话
     const reverseConversation = new Conversation();
     reverseConversation.id = generateUUID();
     reverseConversation.userId = receiverId;
     reverseConversation.otherUserId = userId;
     reverseConversation.lastMessage = '';
     reverseConversation.lastMessageTime = new Date();
     reverseConversation.unreadCount = 0;
     await conversationRepository.save(reverseConversation);
   }
   ```

4. **创建消息记录**
   ```typescript
   const message = new Message();
   message.id = generateUUID();
   message.conversationId = conversation.id;
   message.senderId = userId;
   message.receiverId = receiverId;
   message.messageType = messageType;
   message.content = content || '';
   message.mediaUrl = mediaUrl;
   message.thumbnailUrl = thumbnailUrl;
   message.duration = duration;
   message.status = 1; // 已送达
   message.isRecalled = false;
   await messageRepository.save(message);
   ```

5. **更新会话信息**
   ```typescript
   const lastMessagePreview = messageType === 'text'
     ? content
     : `[${messageType === 'image' ? '图片' : messageType === 'voice' ? '语音' : '视频'}]`;

   await conversationRepository.update(
     { id: conversation.id },
     {
       lastMessage: lastMessagePreview,
       lastMessageTime: message.createdAt
     }
   );

   // 更新对方会话的未读数
   await conversationRepository
     .createQueryBuilder()
     .update(Conversation)
     .set({
       unreadCount: () => 'unreadCount + 1',
       lastMessage: lastMessagePreview,
       lastMessageTime: message.createdAt
     })
     .where('userId = :receiverId', { receiverId })
     .andWhere('otherUserId = :userId', { userId })
     .execute();
   ```

6. **WebSocket推送**
   ```typescript
   webSocketService.sendToUser(receiverId, {
     type: 'new_message',
     conversationId: conversation.id,
     message: {
       messageId: message.id,
       conversationId: message.conversationId,
       senderId: message.senderId,
       receiverId: message.receiverId,
       messageType: message.messageType,
       content: message.content,
       mediaUrl: message.mediaUrl,
       thumbnailUrl: message.thumbnailUrl,
       duration: message.duration,
       status: message.status,
       createdAt: message.createdAt.toISOString()
     }
   });
   ```

7. **离线通知**
   ```typescript
   const isOnline = await redis.get(`online:${receiverId}`);
   if (!isOnline) {
     // 发送离线推送通知
     await pushNotificationService.send({
       userId: receiverId,
       title: `${senderNickname}给你发来一条消息`,
       body: lastMessagePreview
     });
   }
   ```

**错误码:**
- 200:成功
- 400:参数错误
- 401:未登录
- 403:对方已拉黑你
- 404:接收者不存在
- 500:发送失败

---

### 接口7:标记消息已读
**接口:** `PUT /api/message/read/{conversationId}`

**请求参数:**
```typescript
{
  conversationId: string;   // 会话ID (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    conversationId: string;
    readCount: number;        // 标记为已读的消息数
  }
}
```

**业务逻辑:**

1. **验证会话权限**
   ```typescript
   const conversation = await conversationRepository.findOne({
     where: { id: conversationId, userId }
   });

   if (!conversation) {
     throw new ForbiddenError('无权限');
   }
   ```

2. **批量更新消息状态**
   ```typescript
   const result = await messageRepository
     .createQueryBuilder()
     .update(Message)
     .set({ status: 2 })
     .where('conversationId = :conversationId', { conversationId })
     .andWhere('receiverId = :userId', { userId })
     .andWhere('status = 1')
     .execute();

   const readCount = result.affected || 0;
   ```

3. **清零未读数**
   ```typescript
   await conversationRepository.update(
     { id: conversationId, userId },
     { unreadCount: 0 }
   );
   ```

4. **WebSocket通知发送者**
   ```typescript
   webSocketService.sendToUser(conversation.otherUserId, {
     type: 'message_read',
     conversationId,
     readCount
   });
   ```

**错误码:**
- 200:成功
- 401:未登录
- 403:无权限
- 404:会话不存在

---

### 接口8:撤回消息
**接口:** `POST /api/message/recall/{messageId}`

**请求参数:**
```typescript
{
  messageId: string;        // 消息ID (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    messageId: string;
    isRecalled: boolean;      // true
    recalledAt: string;
  }
}
```

**业务逻辑:**

1. **查询消息**
   ```typescript
   const message = await messageRepository.findOne({
     where: { id: messageId }
   });

   if (!message) {
     throw new NotFoundError('消息不存在');
   }
   ```

2. **验证权限**
   ```typescript
   if (message.senderId !== userId) {
     throw new ForbiddenError('只能撤回自己发送的消息');
   }
   ```

3. **验证时间(2分钟内)**
   ```typescript
   const now = new Date();
   const timeDiff = now.getTime() - message.createdAt.getTime();
   const twoMinutes = 2 * 60 * 1000;

   if (timeDiff > twoMinutes) {
     throw new ValidationError('超过2分钟,无法撤回');
   }
   ```

4. **更新消息状态**
   ```typescript
   message.isRecalled = true;
   message.recalledAt = new Date();
   await messageRepository.save(message);
   ```

5. **WebSocket通知接收者**
   ```typescript
   webSocketService.sendToUser(message.receiverId, {
     type: 'message_recalled',
     messageId: message.id,
     conversationId: message.conversationId
   });
   ```

**错误码:**
- 200:成功
- 400:超过2分钟,无法撤回
- 401:未登录
- 403:无权限撤回
- 404:消息不存在

---

### 接口9:删除消息
**接口:** `DELETE /api/message/{messageId}`

**请求参数:**
```typescript
{
  messageId: string;        // 消息ID (路径参数)
}
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: null
}
```

**业务逻辑:**

1. **验证权限**
   ```typescript
   const message = await messageRepository.findOne({
     where: { id: messageId }
   });

   if (!message) {
     throw new NotFoundError('消息不存在');
   }

   // 只能删除与自己相关的消息
   if (message.senderId !== userId && message.receiverId !== userId) {
     throw new ForbiddenError('无权限删除该消息');
   }
   ```

2. **软删除**
   ```typescript
   message.deleted = 1;
   message.deletedAt = new Date();
   await messageRepository.save(message);
   ```

**错误码:**
- 200:成功
- 401:未登录
- 403:无权限
- 404:消息不存在

---

### 接口10:上传媒体文件
**接口:** `POST /api/message/upload`

**请求参数:**
```typescript
FormData:
  file: File;               // 文件对象
  type: string;             // 文件类型:image/voice/video
```

**响应数据:**
```typescript
{
  code: number;
  message: string;
  data: {
    mediaUrl: string;
    thumbnailUrl?: string;    // 缩略图(视频)
    width?: number;           // 宽度(图片/视频)
    height?: number;          // 高度(图片/视频)
    duration?: number;        // 时长(语音/视频)
    fileSize: number;         // 文件大小
  }
}
```

**业务逻辑:**

1. **文件验证**
   ```typescript
   const validateFile = (file: File, type: string) => {
     const limits = {
       image: { types: ['image/jpeg', 'image/png', 'image/gif'], maxSize: 10 * 1024 * 1024 },
       voice: { types: ['audio/mp3', 'audio/wav', 'audio/m4a'], maxSize: 2 * 1024 * 1024 },
       video: { types: ['video/mp4', 'video/quicktime'], maxSize: 50 * 1024 * 1024 }
     };

     const limit = limits[type];
     if (!limit.types.includes(file.mimetype)) {
       throw new ValidationError('文件类型不支持');
     }

     if (file.size > limit.maxSize) {
       throw new ValidationError('文件过大');
     }
   };
   ```

2. **上传到OSS**
   ```typescript
   const uploadToOSS = async (file: File) => {
     const filename = `${Date.now()}-${file.originalname}`;
     const key = `messages/${type}/${filename}`;

     const result = await ossClient.put(key, file.buffer);
     return result.url;
   };
   ```

3. **图片处理**
   ```typescript
   if (type === 'image') {
     // 如果图片>2MB,生成缩略图
     if (file.size > 2 * 1024 * 1024) {
       const thumbnail = await sharp(file.buffer)
         .resize(800, 800, { fit: 'inside' })
         .jpeg({ quality: 80 })
         .toBuffer();

       const thumbnailUrl = await uploadToOSS(thumbnail);
       return { mediaUrl, thumbnailUrl };
     }
   }
   ```

4. **视频处理**
   ```typescript
   if (type === 'video') {
     // 生成封面(首帧)
     const thumbnailBuffer = await ffmpeg(file.buffer)
       .screenshots({
         count: 1,
         timestamps: ['00:00:01']
       });

     const thumbnailUrl = await uploadToOSS(thumbnailBuffer);
     return { mediaUrl, thumbnailUrl };
   }
   ```

**错误码:**
- 200:成功
- 400:文件类型不支持 / 文件过大
- 401:未登录
- 500:上传失败

---

## 数据模型

### Conversation (会话表)

```typescript
@Entity('conversation')
class Conversation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;           // 用户ID

  @Column()
  otherUserId: string;      // 对方用户ID

  @Column({ type: 'text' })
  lastMessage: string;      // 最后一条消息内容

  @Column({ type: 'timestamp' })
  lastMessageTime: Date;    // 最后消息时间

  @Column({ type: 'int', default: 0 })
  unreadCount: number;      // 未读消息数

  @Column({ type: 'tinyint', default: 0 })
  deleted: number;          // 是否已删除:0=否,1=是

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;          // 删除时间

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['userId', 'deleted'])
  @Index(['userId', 'otherUserId', 'deleted'])
  @Index(['lastMessageTime'])
}
```

---

### Message (消息表)

```typescript
@Entity('message')
class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  conversationId: string;   // 会话ID

  @Column()
  senderId: string;         // 发送者ID

  @Column()
  receiverId: string;       // 接收者ID

  @Column({ length: 20 })
  messageType: string;      // 消息类型:text/image/voice/video

  @Column({ type: 'text' })
  content: string;          // 消息内容(文字消息)

  @Column({ nullable: true })
  mediaUrl: string;         // 媒体URL(图片/语音/视频)

  @Column({ nullable: true })
  thumbnailUrl: string;     // 缩略图URL(视频)

  @Column({ type: 'int', nullable: true })
  duration: number;         // 时长(语音/视频,秒)

  @Column({ type: 'tinyint', default: 0 })
  status: number;           // 状态:0=发送中,1=已送达,2=已读,3=失败

  @Column({ type: 'tinyint', default: 0 })
  isRecalled: boolean;      // 是否已撤回

  @Column({ type: 'timestamp', nullable: true })
  recalledAt: Date;         // 撤回时间

  @Column({ type: 'tinyint', default: 0 })
  deleted: number;          // 是否已删除

  @Column({ type: 'timestamp', nullable: true })
  deletedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['conversationId', 'deleted', 'createdAt'])
  @Index(['senderId', 'receiverId'])
  @Index(['status'])
}
```

---

## RPC接口实现

### ChatService RPC接口

提供给其他服务调用的RPC方法:

```typescript
class ChatService {
  /**
   * 获取用户会话列表
   * @param userId 用户ID
   * @param page 页码
   * @param pageSize 每页数量
   * @return 会话列表
   */
  async getUserConversations(params: {
    userId: string;
    page: number;
    pageSize: number;
  }): Promise<ConversationListResult> {
    const { userId, page, pageSize } = params;

    const query = conversationRepository
      .createQueryBuilder('c')
      .where('c.userId = :userId', { userId })
      .andWhere('c.deleted = 0')
      .orderBy('c.lastMessageTime', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize);

    const [conversations, total] = await query.getManyAndCount();

    return {
      list: conversations,
      total,
      hasMore: total > page * pageSize
    };
  }

  /**
   * 获取用户未读消息数
   * @param userId 用户ID
   * @return 未读消息数
   */
  async getUserUnreadCount(params: {
    userId: string;
  }): Promise<number> {
    const { userId } = params;

    const result = await conversationRepository
      .createQueryBuilder('c')
      .select('SUM(c.unreadCount)', 'total')
      .where('c.userId = :userId', { userId })
      .andWhere('c.deleted = 0')
      .getRawOne();

    return result.total || 0;
  }

  /**
   * 获取会话消息列表
   * @param conversationId 会话ID
   * @param page 页码
   * @param pageSize 每页数量
   * @return 消息列表
   */
  async getConversationMessages(params: {
    conversationId: string;
    page: number;
    pageSize: number;
  }): Promise<MessageListResult> {
    const { conversationId, page, pageSize } = params;

    const query = messageRepository
      .createQueryBuilder('m')
      .where('m.conversationId = :conversationId', { conversationId })
      .andWhere('m.deleted = 0')
      .orderBy('m.createdAt', 'DESC')
      .skip((page - 1) * pageSize)
      .take(pageSize);

    const [messages, total] = await query.getManyAndCount();

    return {
      list: messages,
      total,
      hasMore: total > page * pageSize
    };
  }
}
```

**其他服务调用示例:**
```typescript
// 在UserService中调用
import { ChatServiceClient } from '@/rpc/ChatServiceClient';

const chatClient = new ChatServiceClient();

// 获取用户会话列表
const conversations = await chatClient.getUserConversations({
  userId: 'user_xxx',
  page: 1,
  pageSize: 20
});
```

---

## WebSocket实现

### WebSocket连接管理

```typescript
class WebSocketService {
  private connections: Map<string, WebSocket> = new Map();

  // 用户连接
  onConnect(userId: string, ws: WebSocket) {
    this.connections.set(userId, ws);

    // 更新在线状态
    redis.setex(`online:${userId}`, 300, '1'); // 5分钟过期

    // 心跳检测
    const heartbeat = setInterval(() => {
      ws.ping();
    }, 30000); // 每30秒ping一次

    ws.on('pong', () => {
      // 收到pong,更新在线状态
      redis.setex(`online:${userId}`, 300, '1');
    });

    ws.on('close', () => {
      this.onDisconnect(userId);
      clearInterval(heartbeat);
    });
  }

  // 用户断开
  onDisconnect(userId: string) {
    this.connections.delete(userId);

    // 删除在线状态
    redis.del(`online:${userId}`);
  }

  // 发送消息给指定用户
  sendToUser(userId: string, data: any) {
    const ws = this.connections.get(userId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(data));
      return true;
    }
    return false;
  }

  // 广播消息
  broadcast(data: any) {
    this.connections.forEach((ws, userId) => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(data));
      }
    });
  }
}
```

### WebSocket事件类型

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

---

## 性能优化

### 1. Redis缓存策略

```typescript
// 未读消息数缓存
const cacheUnreadCount = async (userId: string) => {
  const key = `unread:count:${userId}`;
  const ttl = 180; // 3分钟

  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const count = await calculateUnreadCount(userId);
  await redis.setex(key, ttl, JSON.stringify(count));

  return count;
};

// 会话列表缓存
const cacheConversationList = async (userId: string, page: number) => {
  const key = `conversation:list:${userId}:page:${page}`;
  const ttl = 300; // 5分钟

  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const list = await getConversationList(userId, page);
  await redis.setex(key, ttl, JSON.stringify(list));

  return list;
};

// 在线状态缓存
const cacheOnlineStatus = async (userId: string, isOnline: boolean) => {
  const key = `online:${userId}`;
  const ttl = 300; // 5分钟

  if (isOnline) {
    await redis.setex(key, ttl, '1');
  } else {
    await redis.del(key);
  }
};
```

### 2. 数据库查询优化

```typescript
// 使用索引优化查询
@Index(['userId', 'deleted'])
@Index(['userId', 'otherUserId', 'deleted'])
@Index(['lastMessageTime'])
@Index(['conversationId', 'deleted', 'createdAt'])

// 批量查询用户信息
const getBatchUserInfo = async (userIds: string[]) => {
  // 批量RPC调用
  return await userServiceClient.getBatchUserInfo(userIds);
};

// 分页查询优化
const getPaginatedMessages = async (
  conversationId: string,
  page: number,
  pageSize: number
) => {
  return await messageRepository
    .createQueryBuilder('m')
    .where('m.conversationId = :conversationId', { conversationId })
    .andWhere('m.deleted = 0')
    .orderBy('m.createdAt', 'DESC')
    .skip((page - 1) * pageSize)
    .take(pageSize)
    .getManyAndCount();
};
```

### 3. WebSocket优化

```typescript
// 消息队列(离线时缓存)
const queueOfflineMessage = async (userId: string, message: any) => {
  const key = `offline:messages:${userId}`;
  await redis.lpush(key, JSON.stringify(message));
  await redis.expire(key, 86400); // 24小时过期
};

// 用户上线时发送离线消息
const sendOfflineMessages = async (userId: string, ws: WebSocket) => {
  const key = `offline:messages:${userId}`;
  const messages = await redis.lrange(key, 0, -1);

  messages.forEach(msg => {
    ws.send(msg);
  });

  await redis.del(key);
};

// 去重处理(防止重复消息)
const deduplicateMessage = async (messageId: string) => {
  const key = `message:sent:${messageId}`;
  const exists = await redis.exists(key);

  if (exists) {
    return false; // 重复消息
  }

  await redis.setex(key, 300, '1'); // 5分钟去重窗口
  return true;
};
```

---

## 监控与日志

### 监控指标

- 消息发送成功率
- 消息送达延迟(P50, P95, P99)
- WebSocket连接数
- 在线用户数
- 消息队列长度
- Redis缓存命中率
- 平均响应时间

### 日志记录

```typescript
logger.info('Message sent', {
  messageId: message.id,
  senderId: message.senderId,
  receiverId: message.receiverId,
  messageType: message.messageType,
  conversationId: message.conversationId
});

logger.warn('Message send failed', {
  error: error.message,
  senderId,
  receiverId,
  messageType
});

logger.info('WebSocket connected', {
  userId,
  ip: req.ip
});

logger.warn('WebSocket disconnected', {
  userId,
  reason: 'timeout'
});
```

---

## 测试用例

### 单元测试
- [ ] 会话列表查询成功
- [ ] 消息发送成功(文字/图片/语音/视频)
- [ ] 消息已读标记成功
- [ ] 消息撤回成功(2分钟内)
- [ ] 消息撤回失败(超过2分钟)
- [ ] 消息删除成功
- [ ] 未读消息数统计正确
- [ ] 会话删除成功

### 集成测试
- [ ] WebSocket连接成功
- [ ] 实时消息推送成功
- [ ] 在线状态同步成功
- [ ] RPC调用成功
- [ ] Redis缓存成功

### 性能测试
- [ ] 消息发送<100ms
- [ ] 消息列表查询<150ms
- [ ] WebSocket消息延迟<500ms
- [ ] 并发1000请求/秒稳定
- [ ] 缓存命中率>80%

---

## 配置参数

### 环境变量

```bash
# 服务配置
PORT=8005
NODE_ENV=production

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_NAME=xypai_chat
DB_USER=root
DB_PASSWORD=password

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# WebSocket配置
WS_PORT=8005
WS_HEARTBEAT_INTERVAL=30000    # 心跳间隔(毫秒)
WS_TIMEOUT=300000              # 超时时间(毫秒)

# OSS配置
OSS_ENDPOINT=https://oss.example.com
OSS_BUCKET=xypai-messages
OSS_ACCESS_KEY_ID=your_key
OSS_ACCESS_KEY_SECRET=your_secret

# 消息配置
MESSAGE_TEXT_MAX_LENGTH=500    # 文字消息最大长度
MESSAGE_RECALL_TIMEOUT=120000  # 撤回超时(毫秒,2分钟)
IMAGE_MAX_SIZE=10485760        # 图片最大大小(字节,10MB)
VOICE_MAX_SIZE=2097152         # 语音最大大小(字节,2MB)
VIDEO_MAX_SIZE=52428800        # 视频最大大小(字节,50MB)

# 缓存配置
CACHE_TTL_UNREAD_COUNT=180     # 未读数缓存时长(秒)
CACHE_TTL_CONVERSATION=300     # 会话列表缓存时长(秒)
CACHE_TTL_ONLINE_STATUS=300    # 在线状态缓存时长(秒)
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

EXPOSE 8005

CMD ["npm", "start"]
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2025-01-XX | 初始版本 |
| 1.1.0 | 待定 | 增加群聊功能 |
| 1.2.0 | 待定 | 增加消息加密 |

---

**文档版本:** v1.0
**创建日期:** 2025-11-14
**所属模块:** 05-chat模块
**维护团队:** 消息团队

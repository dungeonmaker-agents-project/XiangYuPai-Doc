# ContentService 后端服务文档

## 服务概述

ContentService是内容模块的核心服务,负责处理动态内容的创建、查询、互动等业务逻辑。该服务提供Feed(动态)、Comment(评论)、Topic(话题)、Interaction(互动)等核心功能。

**服务名称:** xypai-content
**服务端口:** 8003
**数据库:** xypai_content
**技术栈:** Node.js + TypeScript + Express + TypeORM + MySQL + Redis

---

## 服务架构

### 模块结构

```
xypai-content/
├── src/
│   ├── controllers/        # 控制器层
│   │   ├── FeedController.ts
│   │   ├── CommentController.ts
│   │   ├── TopicController.ts
│   │   └── InteractionController.ts
│   ├── services/           # 业务逻辑层
│   │   ├── FeedService.ts
│   │   ├── CommentService.ts
│   │   ├── TopicService.ts
│   │   ├── InteractionService.ts
│   │   └── RecommendService.ts
│   ├── models/             # 数据模型层
│   │   ├── Feed.ts
│   │   ├── Comment.ts
│   │   ├── Topic.ts
│   │   ├── Like.ts
│   │   ├── Collection.ts
│   │   ├── Share.ts
│   │   └── Report.ts
│   ├── repositories/       # 数据访问层
│   │   ├── FeedRepository.ts
│   │   ├── CommentRepository.ts
│   │   ├── TopicRepository.ts
│   │   └── InteractionRepository.ts
│   ├── rpc/                # RPC客户端
│   │   ├── UserServiceClient.ts
│   │   ├── MediaServiceClient.ts
│   │   └── LocationServiceClient.ts
│   ├── middlewares/        # 中间件
│   │   ├── auth.ts
│   │   ├── validation.ts
│   │   └── errorHandler.ts
│   ├── utils/              # 工具函数
│   │   ├── cache.ts
│   │   ├── pagination.ts
│   │   └── recommendation.ts
│   └── app.ts              # 应用入口
```

### 依赖服务

**RPC调用:**
- **UserService (xypai-user:8002):**
  - `getUserInfo(userId)` - 获取用户信息
  - `getBatchUserInfo(userIds[])` - 批量获取用户信息

- **MediaUploadService (06-common模块):**
  - `uploadMedia(file, type)` - 上传媒体文件

- **LocationService (06-common模块):**
  - `getNearbyLocations(lat, lon, radius)` - 获取附近地点
  - `searchLocations(keyword)` - 搜索地点

---

## API接口列表

### 1. Feed Management (动态管理)

#### 1.1 获取动态列表

**接口:** `GET /api/v1/content/feed/{tabType}`

**路径参数:**
- `tabType`: 'follow' | 'hot' | 'local'

**查询参数:**
```typescript
{
  page: number;        // 页码,从1开始,默认1
  pageSize: number;    // 每页数量,默认20,最大100
  latitude?: number;   // 同城Tab必传: 用户纬度
  longitude?: number;  // 同城Tab必传: 用户经度
  radius?: number;     // 同城Tab可选: 搜索半径(km),默认5
}
```

**业务逻辑:**
1. 验证参数
2. 根据tabType查询不同数据源:
   - **follow**: 查询用户关注的人的动态
     - 调用UserService.getFollowingList()获取关注列表
     - 查询关注用户的动态
     - 按时间倒序排序
   - **hot**: 查询热门动态
     - 使用推荐算法计算热度分数
     - 热度分 = 点赞数 * 1 + 评论数 * 2 + 分享数 * 3 + 收藏数 * 2
     - 时间衰减: 24小时内全分,每24小时衰减50%
     - 按热度分倒序排序
   - **local**: 查询同城动态
     - 验证经纬度参数
     - 使用Geohash或MySQL空间索引查询
     - 计算距离,按距离正序排序
3. 调用UserService.getBatchUserInfo()批量获取用户信息
4. 组装Feed数据(包含userInfo, mediaList, topicList等)
5. 查询当前用户的互动状态(isLiked, isCollected)
6. 返回列表数据

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [
      {
        "id": "feed_xxx",
        "userId": "user_xxx",
        "type": 1,
        "content": "动态内容...",
        "userInfo": {
          "id": "user_xxx",
          "nickname": "用户昵称",
          "avatar": "https://cdn.example.com/avatar.jpg",
          "isFollowed": false
        },
        "mediaList": [],
        "topicList": [],
        "likeCount": 123,
        "commentCount": 45,
        "shareCount": 12,
        "collectCount": 67,
        "isLiked": false,
        "isCollected": false,
        "createdAt": 1234567890000
      }
    ],
    "total": 100,
    "hasMore": true
  }
}
```

---

#### 1.2 获取动态详情

**接口:** `GET /api/v1/content/detail/{feedId}`

**路径参数:**
- `feedId`: 动态ID

**业务逻辑:**
1. 根据feedId查询动态记录
2. 验证动态可见性:
   - visibility=0(公开): 所有人可见
   - visibility=1(仅好友): 需要是好友关系
   - visibility=2(仅自己): 只有作者本人可见
3. 调用UserService.getUserInfo()获取作者信息
4. 查询媒体列表
5. 查询话题列表
6. 查询当前用户的互动状态(isLiked, isCollected)
7. 判断权限(canEdit, canDelete)
8. 异步更新浏览数(+1),使用Redis计数器
9. 返回完整详情

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "feed_xxx",
    "userId": "user_xxx",
    "type": 1,
    "title": "动态标题",
    "content": "动态内容...",
    "userInfo": { ... },
    "mediaList": [ ... ],
    "topicList": [ ... ],
    "locationName": "深圳市南山区",
    "likeCount": 123,
    "commentCount": 45,
    "isLiked": false,
    "isCollected": false,
    "canEdit": false,
    "canDelete": false,
    "createdAt": 1234567890000
  }
}
```

---

#### 1.3 发布动态

**接口:** `POST /api/v1/content/publish`

**请求体:**
```typescript
{
  type: number;              // 1=动态,2=活动,3=技能
  title?: string;            // 0-50字符
  content: string;           // 1-1000字符
  mediaIds: string[];        // 最多9张图或1个视频
  topicNames: string[];      // 最多5个话题
  locationId?: string;
  locationName?: string;
  locationAddress?: string;
  longitude?: number;
  latitude?: number;
  visibility?: number;       // 0=公开,1=仅好友,2=仅自己
}
```

**业务逻辑:**
1. 验证用户登录状态(从JWT Token获取userId)
2. 验证内容格式:
   - content: 1-1000字符,必填
   - title: 0-50字符,可选
   - mediaIds: 最多9张图或1个视频
   - topicNames: 最多5个,每个1-20字符
3. 创建Feed记录
4. 关联媒体资源(插入feed_media表)
5. 处理话题标签:
   - 查询话题是否存在
   - 不存在则创建新话题
   - 创建feed_topic关联记录
   - 更新话题的帖子数(+1)
6. 保存地理位置信息
7. 异步任务:
   - 推送通知给粉丝(使用消息队列)
   - 更新用户发帖数(+1)
   - 内容审核(敏感词检测)
8. 返回feedId和createdAt

**响应示例:**
```json
{
  "code": 200,
  "message": "发布成功",
  "data": {
    "feedId": "feed_xxx",
    "createdAt": 1234567890000
  }
}
```

---

#### 1.4 删除动态

**接口:** `DELETE /api/v1/content/{feedId}`

**路径参数:**
- `feedId`: 动态ID

**业务逻辑:**
1. 验证用户登录状态
2. 查询动态记录
3. 验证权限(只能删除自己的动态)
4. 软删除动态记录(设置deleted=1)
5. 异步任务:
   - 删除关联的评论
   - 删除关联的点赞/收藏记录
   - 更新话题的帖子数(-1)
   - 更新用户发帖数(-1)
6. 返回成功

**响应示例:**
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

---

### 2. Comment Management (评论管理)

#### 2.1 获取评论列表

**接口:** `GET /api/v1/content/comments/{feedId}`

**路径参数:**
- `feedId`: 动态ID

**查询参数:**
```typescript
{
  page: number;        // 页码,默认1
  pageSize: number;    // 每页数量,默认20
  sortType?: 'time' | 'hot' | 'like';  // 排序方式,默认time
}
```

**业务逻辑:**
1. 验证feedId存在
2. 查询一级评论(parentId IS NULL):
   - sortType=time: 按创建时间倒序
   - sortType=hot: 按点赞数倒序
   - sortType=like: 按点赞数倒序
   - 置顶评论优先显示
3. 对每个一级评论,查询前3条二级回复
4. 调用UserService.getBatchUserInfo()批量获取用户信息
5. 查询当前用户的点赞状态(isLiked)
6. 判断删除权限(canDelete)
7. 返回评论列表

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [
      {
        "id": "comment_xxx",
        "feedId": "feed_xxx",
        "userId": "user_xxx",
        "content": "评论内容",
        "userInfo": { ... },
        "likeCount": 5,
        "replyCount": 10,
        "isTop": false,
        "isLiked": false,
        "replies": [
          {
            "id": "reply_xxx",
            "content": "回复内容",
            "userInfo": { ... },
            "replyToUserNickname": "被回复用户",
            "createdAt": 1234567890000
          }
        ],
        "totalReplies": 10,
        "hasMoreReplies": true,
        "canDelete": false,
        "createdAt": 1234567890000
      }
    ],
    "total": 45,
    "hasMore": true
  }
}
```

---

#### 2.2 发布评论

**接口:** `POST /api/v1/content/comment`

**请求体:**
```typescript
{
  feedId: string;        // 动态ID
  content: string;       // 1-500字符
  parentId?: string;     // 回复的一级评论ID(可选)
  replyToUserId?: string; // 回复的用户ID(可选)
}
```

**业务逻辑:**
1. 验证用户登录状态
2. 验证feedId存在且可评论
3. 验证内容格式(1-500字符)
4. 如果是二级回复,验证parentId和replyToUserId
5. 创建Comment记录
6. 更新动态的评论数(+1)
7. 如果是二级回复,更新一级评论的回复数(+1)
8. 调用UserService.getUserInfo()获取当前用户信息
9. 异步任务:
   - 发送通知给动态作者
   - 如果是回复,发送通知给被回复用户
10. 返回新评论数据

**响应示例:**
```json
{
  "code": 200,
  "message": "评论成功",
  "data": {
    "comment": {
      "id": "comment_xxx",
      "feedId": "feed_xxx",
      "userId": "user_xxx",
      "content": "评论内容",
      "userInfo": { ... },
      "likeCount": 0,
      "replyCount": 0,
      "isLiked": false,
      "canDelete": true,
      "createdAt": 1234567890000
    }
  }
}
```

---

#### 2.3 删除评论

**接口:** `DELETE /api/v1/content/comment/{commentId}`

**路径参数:**
- `commentId`: 评论ID

**业务逻辑:**
1. 验证用户登录状态
2. 查询评论记录
3. 验证权限(只能删除自己的评论)
4. 软删除评论记录
5. 更新动态的评论数(-1)
6. 如果是一级评论:
   - 删除所有二级回复
   - 评论数减去回复数量
7. 如果是二级回复:
   - 更新一级评论的回复数(-1)
8. 返回成功

**响应示例:**
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

---

### 3. Topic Management (话题管理)

#### 3.1 获取热门话题

**接口:** `GET /api/v1/content/topics/hot`

**查询参数:**
```typescript
{
  page: number;        // 页码,默认1
  pageSize: number;    // 每页数量,默认20
}
```

**业务逻辑:**
1. 从Redis缓存读取热门话题(缓存1小时)
2. 缓存未命中,查询数据库:
   - 按参与人数倒序排序
   - 或按帖子数倒序排序
   - 或综合热度分排序
3. 返回话题列表

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [
      {
        "name": "探店日记",
        "description": "分享你的探店体验",
        "participantCount": 1254,
        "postCount": 12545,
        "coverImage": "https://cdn.example.com/topic.jpg",
        "isOfficial": true,
        "isHot": true
      }
    ],
    "total": 100,
    "hasMore": true
  }
}
```

---

#### 3.2 搜索话题

**接口:** `GET /api/v1/content/topics/search`

**查询参数:**
```typescript
{
  keyword: string;     // 搜索关键词,1-20字符
  page: number;
  pageSize: number;
}
```

**业务逻辑:**
1. 验证关键词(1-20字符)
2. 使用LIKE查询或全文检索:
   - `WHERE name LIKE '%keyword%'`
   - 或使用Elasticsearch全文检索
3. 按参与人数倒序排序
4. 返回话题列表

---

### 4. Interaction Management (互动管理)

#### 4.1 点赞/取消点赞

**接口:** `POST /api/v1/interaction/like`

**请求体:**
```typescript
{
  targetType: 'feed' | 'comment';  // 目标类型
  targetId: string;                // 目标ID
  action: 'like' | 'unlike';       // 操作类型
}
```

**业务逻辑:**
1. 验证用户登录状态
2. 验证targetType和targetId
3. 查询目标记录是否存在
4. 检查点赞状态:
   - action=like:
     - 已点赞: 返回错误"已经点赞过了"
     - 未点赞: 创建点赞记录
   - action=unlike:
     - 未点赞: 返回错误"还没有点赞"
     - 已点赞: 删除点赞记录
5. 更新目标记录的点赞数(+1或-1)
   - 使用Redis计数器实现,定期同步到MySQL
6. 返回最新状态

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "likeCount": 124,
    "isLiked": true
  }
}
```

---

#### 4.2 收藏/取消收藏

**接口:** `POST /api/v1/interaction/collect`

**请求体:**
```typescript
{
  targetType: 'feed';              // 当前仅支持feed
  targetId: string;
  action: 'collect' | 'uncollect';
}
```

**业务逻辑:**
1. 验证用户登录状态
2. 验证targetId(动态)存在
3. 检查收藏状态:
   - action=collect:
     - 已收藏: 返回错误"已经收藏过了"
     - 未收藏: 创建收藏记录
   - action=uncollect:
     - 未收藏: 返回错误"还没有收藏"
     - 已收藏: 删除收藏记录
4. 更新动态的收藏数(+1或-1)
5. 返回最新状态

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "collectCount": 68,
    "isCollected": true
  }
}
```

---

#### 4.3 分享

**接口:** `POST /api/v1/interaction/share`

**请求体:**
```typescript
{
  targetType: 'feed';
  targetId: string;
  shareChannel: 'wechat' | 'moments' | 'qq' | 'qzone' | 'weibo' | 'copy_link';
}
```

**业务逻辑:**
1. 验证targetId(动态)存在
2. 生成分享链接(Deep Link):
   - `https://app.xiangyupai.com/feed/{feedId}`
3. 查询动态信息,生成分享内容:
   - shareTitle: 动态标题或截取内容前30字
   - shareDesc: 动态内容摘要
   - shareImage: 封面图或第一张图片
4. 创建分享记录(记录分享渠道和时间)
5. 更新动态的分享数(+1)
   - 使用Redis计数器
6. 返回分享内容

**响应示例:**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "shareUrl": "https://app.xiangyupai.com/feed/xxx",
    "shareTitle": "动态标题",
    "shareDesc": "动态内容摘要...",
    "shareImage": "https://cdn.example.com/cover.jpg",
    "shareCount": 13
  }
}
```

---

### 5. Moderation (内容审核)

#### 5.1 举报内容/用户

**接口:** `POST /api/v1/content/report`

**请求体:**
```typescript
{
  targetType: 'feed' | 'comment' | 'user';
  targetId: string;
  reasonType: string;      // harassment/pornography/fraud/illegal/...
  description?: string;    // 0-200字符
  evidenceImages?: string[]; // 最多3张
}
```

**业务逻辑:**
1. 验证用户登录状态
2. 验证targetType和targetId
3. 验证reasonType(从预定义列表中选择)
4. 检查重复举报:
   - 24小时内同一用户对同一目标只能举报1次
5. 创建举报记录
6. 异步任务:
   - 推送到审核队列
   - 发送通知给管理员
   - 如果累计举报超过阈值,自动下架内容
7. 返回举报ID

**响应示例:**
```json
{
  "code": 200,
  "message": "已收到您的举报,我们会尽快处理",
  "data": {
    "reportId": "report_xxx",
    "createdAt": 1234567890000,
    "status": "pending"
  }
}
```

---

#### 5.2 查看我的举报记录(可选)

**接口:** `GET /api/v1/user/reports`

**查询参数:**
```typescript
{
  page: number;
  pageSize: number;
  status?: 'pending' | 'processing' | 'approved' | 'rejected';
}
```

**业务逻辑:**
1. 验证用户登录状态
2. 查询当前用户的举报记录
3. 可按状态筛选
4. 返回举报列表

---

## 数据模型

### Feed (动态表)

```typescript
@Entity('feed')
class Feed {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;           // 用户ID

  @Column({ type: 'tinyint' })
  type: number;             // 1=动态,2=活动,3=技能

  @Column({ length: 50, nullable: true })
  title: string;            // 标题

  @Column({ type: 'text' })
  content: string;          // 内容

  @Column({ length: 255, nullable: true })
  coverImage: string;       // 封面图

  @Column({ length: 100, nullable: true })
  locationName: string;     // 地点名称

  @Column({ length: 255, nullable: true })
  locationAddress: string;  // 详细地址

  @Column({ type: 'decimal', precision: 10, scale: 6, nullable: true })
  longitude: number;        // 经度

  @Column({ type: 'decimal', precision: 10, scale: 6, nullable: true })
  latitude: number;         // 纬度

  @Column({ type: 'int', nullable: true })
  cityId: number;           // 城市ID

  @Column({ type: 'int', default: 0 })
  likeCount: number;

  @Column({ type: 'int', default: 0 })
  commentCount: number;

  @Column({ type: 'int', default: 0 })
  shareCount: number;

  @Column({ type: 'int', default: 0 })
  collectCount: number;

  @Column({ type: 'int', default: 0 })
  viewCount: number;

  @Column({ type: 'tinyint', default: 0 })
  visibility: number;       // 0=公开,1=仅好友,2=仅自己

  @Column({ type: 'tinyint', default: 0 })
  status: number;           // 0=正常,1=审核中,2=已下架

  @Column({ type: 'tinyint', default: 0 })
  deleted: number;          // 0=未删除,1=已删除

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index()
  @Column({ type: 'bigint' })
  createdTimestamp: number; // 创建时间戳,用于排序

  @Index(['userId', 'deleted'])
  @Index(['type', 'status', 'deleted'])
  @Index(['createdTimestamp'])
}
```

---

### Comment (评论表)

```typescript
@Entity('comment')
class Comment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  feedId: string;

  @Column()
  userId: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  parentId: string;         // NULL=一级评论

  @Column({ nullable: true })
  replyToUserId: string;

  @Column({ type: 'int', default: 0 })
  likeCount: number;

  @Column({ type: 'int', default: 0 })
  replyCount: number;

  @Column({ type: 'tinyint', default: 0 })
  isTop: number;            // 是否置顶

  @Column({ type: 'tinyint', default: 0 })
  deleted: number;

  @CreateDateColumn()
  createdAt: Date;

  @Index(['feedId', 'parentId', 'deleted'])
  @Index(['userId', 'deleted'])
}
```

---

### Topic (话题表)

```typescript
@Entity('topic')
class Topic {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 50, unique: true })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 255, nullable: true })
  coverImage: string;

  @Column({ type: 'int', default: 0 })
  participantCount: number; // 参与人数

  @Column({ type: 'int', default: 0 })
  postCount: number;        // 帖子数

  @Column({ type: 'tinyint', default: 0 })
  isOfficial: number;       // 官方话题

  @Column({ type: 'tinyint', default: 0 })
  isHot: number;            // 热门话题

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['name'])
  @Index(['postCount'])
}
```

---

### Like (点赞表)

```typescript
@Entity('like')
class Like {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ length: 20 })
  targetType: string;       // feed/comment

  @Column()
  targetId: string;

  @CreateDateColumn()
  createdAt: Date;

  @Index(['userId', 'targetType', 'targetId'], { unique: true })
  @Index(['targetType', 'targetId'])
}
```

---

### Collection (收藏表)

```typescript
@Entity('collection')
class Collection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ length: 20 })
  targetType: string;       // feed

  @Column()
  targetId: string;

  @CreateDateColumn()
  createdAt: Date;

  @Index(['userId', 'targetType', 'targetId'], { unique: true })
  @Index(['userId', 'createdAt'])
}
```

---

### Share (分享表)

```typescript
@Entity('share')
class Share {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ length: 20 })
  targetType: string;       // feed

  @Column()
  targetId: string;

  @Column({ length: 50 })
  shareChannel: string;     // wechat/moments/qq/...

  @CreateDateColumn()
  createdAt: Date;

  @Index(['userId', 'createdAt'])
  @Index(['targetType', 'targetId'])
}
```

---

### Report (举报表)

```typescript
@Entity('report')
class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;           // 举报人

  @Column({ length: 20 })
  targetType: string;       // feed/comment/user

  @Column()
  targetId: string;

  @Column({ length: 50 })
  reasonType: string;       // harassment/pornography/...

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'json', nullable: true })
  evidenceImages: string[]; // JSON数组

  @Column({ length: 20, default: 'pending' })
  status: string;           // pending/processing/approved/rejected

  @Column({ type: 'text', nullable: true })
  result: string;           // 审核结果说明

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Index(['userId', 'targetType', 'targetId', 'createdAt'])
  @Index(['status'])
}
```

---

## RPC接口实现

### UserServiceClient

```typescript
class UserServiceClient {
  private rpcClient: RPCClient;

  constructor() {
    this.rpcClient = new RPCClient('xypai-user', 8002);
  }

  // 获取单个用户信息
  async getUserInfo(userId: string): Promise<UserInfo> {
    try {
      const response = await this.rpcClient.call('getUserInfo', { userId });
      return response.data;
    } catch (error) {
      console.error('RPC getUserInfo failed:', error);
      // 返回默认用户信息
      return {
        id: userId,
        nickname: '未知用户',
        avatar: 'default_avatar.jpg'
      };
    }
  }

  // 批量获取用户信息
  async getBatchUserInfo(userIds: string[]): Promise<Map<string, UserInfo>> {
    try {
      const response = await this.rpcClient.call('getBatchUserInfo', { userIds });
      return new Map(Object.entries(response.data));
    } catch (error) {
      console.error('RPC getBatchUserInfo failed:', error);
      return new Map();
    }
  }

  // 获取用户关注列表
  async getFollowingList(userId: string): Promise<string[]> {
    try {
      const response = await this.rpcClient.call('getFollowingList', { userId });
      return response.data.followingIds;
    } catch (error) {
      console.error('RPC getFollowingList failed:', error);
      return [];
    }
  }
}
```

---

## 缓存策略

### Redis缓存设计

**1. 热门动态列表缓存:**
- Key: `feed:hot:page:{page}`
- 过期时间: 5分钟
- 数据结构: JSON字符串

**2. 动态详情缓存:**
- Key: `feed:detail:{feedId}`
- 过期时间: 10分钟
- 数据结构: JSON字符串

**3. 评论列表缓存:**
- Key: `comment:list:{feedId}:page:{page}`
- 过期时间: 5分钟
- 数据结构: JSON字符串

**4. 互动计数器(点赞/收藏/分享/浏览):**
- Key: `count:{type}:{targetId}` (如: `count:like:feed_xxx`)
- 数据结构: String (数字)
- 定时任务: 每分钟同步到MySQL

**5. 热门话题缓存:**
- Key: `topic:hot`
- 过期时间: 1小时
- 数据结构: JSON数组

---

## 性能优化

### 1. 数据库优化

**索引优化:**
- feed表:
  - 复合索引: `(userId, deleted)`
  - 复合索引: `(type, status, deleted)`
  - 单列索引: `createdTimestamp`
- comment表:
  - 复合索引: `(feedId, parentId, deleted)`
- like表:
  - 唯一索引: `(userId, targetType, targetId)`

**查询优化:**
- 使用SELECT指定字段,避免SELECT *
- 分页查询使用LIMIT优化
- 使用JOIN避免N+1查询
- 使用EXPLAIN分析慢查询

### 2. 缓存优化

**多级缓存:**
- L1: 本地内存缓存(LRU,容量1000条)
- L2: Redis缓存
- L3: MySQL数据库

**缓存预热:**
- 服务启动时预加载热门动态
- 定时更新热门话题缓存

**缓存穿透防护:**
- 布隆过滤器检测不存在的feedId
- 空结果缓存(TTL 1分钟)

### 3. 异步处理

**消息队列:**
- 使用RabbitMQ或Kafka处理异步任务
- 任务类型:
  - 发送通知(评论/点赞)
  - 更新统计数据
  - 内容审核
  - 推荐算法计算

### 4. 推荐算法

**热门动态推荐:**
- 热度分 = 点赞数 * 1 + 评论数 * 2 + 分享数 * 3 + 收藏数 * 2
- 时间衰减因子: `score * Math.pow(0.5, hoursSinceCreated / 24)`
- 去重: 用户已浏览的动态不再推荐

**关注流推荐:**
- 查询关注用户的最新动态
- 按时间倒序排序
- 插入系统推荐内容(每10条插入1条热门)

---

## 错误码定义

| 错误码 | 说明 | HTTP状态码 |
|--------|------|-----------|
| 200 | 成功 | 200 |
| 400 | 参数错误 | 400 |
| 401 | 未登录 | 401 |
| 403 | 权限不足 | 403 |
| 404 | 资源不存在 | 404 |
| 413 | 内容过大 | 413 |
| 429 | 请求过于频繁 | 429 |
| 500 | 服务器错误 | 500 |

**业务错误码:**
- 40001: 内容格式不正确
- 40002: 动态不存在或已删除
- 40003: 评论不存在或已删除
- 40004: 话题不存在
- 40005: 已经点赞过了
- 40006: 还没有点赞
- 40007: 已经收藏过了
- 40008: 还没有收藏
- 40009: 重复举报
- 40010: 图片和视频不能同时上传
- 40011: 媒体数量超过限制
- 40012: 话题数量超过限制

---

## 监控与日志

### 监控指标

**服务监控:**
- QPS (每秒请求数)
- 响应时间 (P50, P95, P99)
- 错误率
- 服务可用性

**业务监控:**
- 发布动态数/小时
- 评论数/小时
- 点赞数/小时
- 活跃用户数

**数据库监控:**
- 慢查询
- 连接池使用率
- 锁等待时间

**Redis监控:**
- 内存使用率
- 命中率
- 连接数

### 日志规范

**日志级别:**
- ERROR: 错误日志(需要告警)
- WARN: 警告日志
- INFO: 信息日志
- DEBUG: 调试日志

**日志格式:**
```
[时间] [级别] [TraceId] [模块] [消息]
```

**关键日志:**
- 接口调用日志(包含userId, 接口路径, 参数, 响应时间)
- RPC调用日志
- 数据库慢查询日志
- 错误日志(包含堆栈信息)

---

## 部署说明

### 环境变量

```bash
# 服务配置
NODE_ENV=production
PORT=8003

# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=password
DB_DATABASE=xypai_content

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# RPC配置
USER_SERVICE_HOST=localhost
USER_SERVICE_PORT=8002
MEDIA_SERVICE_HOST=localhost
MEDIA_SERVICE_PORT=8006
LOCATION_SERVICE_HOST=localhost
LOCATION_SERVICE_PORT=8007

# JWT密钥
JWT_SECRET=your_jwt_secret

# OSS配置
OSS_ENDPOINT=
OSS_ACCESS_KEY=
OSS_SECRET_KEY=
OSS_BUCKET=

# 消息队列
MQ_HOST=localhost
MQ_PORT=5672
MQ_USERNAME=guest
MQ_PASSWORD=guest
```

### Docker部署

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 8003

CMD ["npm", "start"]
```

### 启动命令

```bash
# 开发环境
npm run dev

# 生产环境
npm run build
npm start

# Docker
docker build -t xypai-content:latest .
docker run -d -p 8003:8003 --name xypai-content xypai-content:latest
```

---

## 测试用例

### 单元测试

**FeedService测试:**
- [ ] 创建动态成功
- [ ] 创建动态失败(内容格式错误)
- [ ] 查询动态列表成功
- [ ] 查询动态详情成功
- [ ] 删除动态成功
- [ ] 删除动态失败(权限不足)

**CommentService测试:**
- [ ] 创建评论成功
- [ ] 创建二级回复成功
- [ ] 查询评论列表成功
- [ ] 删除评论成功

**InteractionService测试:**
- [ ] 点赞成功
- [ ] 取消点赞成功
- [ ] 重复点赞失败
- [ ] 收藏成功
- [ ] 分享成功

### 集成测试

- [ ] 发布动态→查询列表→查看详情
- [ ] 发布评论→查询评论列表
- [ ] 点赞→查询点赞状态
- [ ] RPC调用UserService成功
- [ ] Redis缓存读写成功

### 性能测试

- [ ] 并发1000请求/秒,响应时间<200ms
- [ ] 动态列表查询<100ms
- [ ] 动态详情查询<150ms
- [ ] 发布动态<300ms
- [ ] 内存占用<1GB

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0.0 | 2025-01-XX | 初始版本,实现基础功能 |
| 1.1.0 | 待定 | 增加推荐算法优化 |
| 1.2.0 | 待定 | 增加视频支持 |
| 2.0.0 | 待定 | 重构为微服务架构 |

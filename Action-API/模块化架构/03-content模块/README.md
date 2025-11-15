# 03-content模块 (内容域)

## 模块概述

**模块职责**: 内容管理、动态发布、评论互动、话题管理、推荐算法

这是应用的**核心业务模块**,提供社交内容相关的所有功能,是用户活跃度和留存的关键模块。

✅ **当前状态**: 模块已完成,文档齐全

---

## 后端服务 (1个)

### ContentService (内容服务) ✅
- **文档**: [Backend/ContentService后端服务.md](./Backend/ContentService后端服务.md)
- **职责**: 动态内容、评论系统、话题管理、互动功能、推荐算法
- **端口**: 8003
- **数据库**: xypai_content
- **API路径**: `/api/v1/content/*`, `/api/v1/interaction/*`
- **接口数**: 20+ 个对外API + RPC接口

**核心功能**:
- Feed流展示(关注/热门/同城3个Tab)
- 动态发布(文字+图片/视频+话题+地点)
- 评论系统(一级评论+二级回复)
- 互动功能(点赞、收藏、分享)
- 话题管理(热门话题、搜索)
- 举报审核(内容审核)

**RPC调用依赖**:
- `UserService.getUserInfo()` - 获取用户信息
- `UserService.getBatchUserInfo()` - 批量获取用户信息
- `UserService.getFollowingList()` - 获取关注列表
- `MediaUploadService.uploadMedia()` - 上传媒体文件
- `LocationService.getNearbyLocations()` - 获取附近地点
- `ReportService.submitReport()` - 提交举报

---

## 前端页面 (3个) ✅

1. **[01-发现主页页面.md](./Frontend/01-发现主页页面.md)** ✅
   - 路由: `/discover/main`
   - 功能: 发现主页,包含关注/热门/同城3个Tab,动态Feed流
   - 主要接口:
     - `GET /api/v1/content/feed/{tabType}` - 获取动态列表
     - `POST /api/v1/interaction/like` - 点赞动态
     - `POST /api/v1/interaction/collect` - 收藏动态
     - `POST /api/v1/interaction/share` - 分享动态

2. **[02-发布动态页面.md](./Frontend/02-发布动态页面.md)** ✅
   - 路由: `/content/publish`
   - 功能: 发布动态,支持文字、图片(最多9张)、视频(1个)、话题(最多5个)、地点
   - 主要接口:
     - `POST /api/v1/content/publish` - 发布动态
     - `POST /api/v1/media/upload` - 上传媒体(RPC调用MediaUploadService)
     - `GET /api/v1/content/topics/hot` - 获取热门话题
     - `GET /api/v1/content/topics/search` - 搜索话题
     - `GET /api/v1/location/nearby` - 获取附近地点(RPC调用LocationService)
     - `GET /api/v1/location/search` - 搜索地点(RPC调用LocationService)

3. **[03-动态详情页面.md](./Frontend/03-动态详情页面.md)** ✅
   - 路由: `/content/detail/{feedId}`
   - 功能: 动态详情,评论列表(一级+二级),发布评论,互动操作
   - 主要接口:
     - `GET /api/v1/content/detail/{feedId}` - 获取动态详情
     - `GET /api/v1/content/comments/{feedId}` - 获取评论列表
     - `POST /api/v1/content/comment` - 发布评论
     - `DELETE /api/v1/content/comment/{commentId}` - 删除评论
     - `POST /api/v1/interaction/like` - 点赞动态/评论
     - `POST /api/v1/interaction/collect` - 收藏动态
     - `POST /api/v1/interaction/share` - 分享动态
     - `DELETE /api/v1/content/{feedId}` - 删除动态
     - `POST /api/v1/content/report` - 举报内容

---

## 核心业务流程

### 浏览动态流程

```
发现主页页面
  1. 进入页面,默认选中"关注"Tab
  2. GET /api/v1/content/feed/follow?page=1&pageSize=20
  ↓
ContentService
  1. 验证用户登录状态
  2. 调用UserService.getFollowingList()获取关注列表
  3. 查询关注用户的动态
  4. 调用UserService.getBatchUserInfo()获取用户信息
  5. 查询当前用户的互动状态(isLiked, isCollected)
  6. 按时间倒序排序
  ↓
客户端
  1. 渲染动态Feed流
  2. 显示用户信息、内容、媒体、互动数据
  3. 支持下拉刷新、上拉加载更多
```

### 发布动态流程

```
发布动态页面
  1. 输入标题(可选)和正文(必填)
  2. 添加图片/视频
     ↓ POST /api/v1/media/upload (RPC调用MediaUploadService)
     ↓ 返回mediaId
  3. 选择话题(最多5个)
     ↓ GET /api/v1/content/topics/hot
  4. 选择地点(可选)
     ↓ GET /api/v1/location/nearby (RPC调用LocationService)
  5. 点击"发布"按钮
  ↓
POST /api/v1/content/publish
  ↓
ContentService
  1. 验证用户登录状态
  2. 验证内容格式(正文1-1000字符,标题0-50字符)
  3. 验证媒体数量(图片≤9张或视频≤1个)
  4. 验证话题数量(≤5个)
  5. 创建动态记录
  6. 关联媒体资源(插入feed_media表)
  7. 处理话题标签(查询或创建话题,创建feed_topic关联)
  8. 保存地理位置信息
  9. 异步任务:
     - 推送通知给粉丝
     - 更新用户发帖数
     - 内容审核(敏感词检测)
  ↓
客户端
  1. 显示"发布成功"Toast
  2. 返回发现主页
  3. 新动态插入列表顶部
```

### 评论互动流程

```
动态详情页面
  1. 查看动态详情
     ↓ GET /api/v1/content/detail/{feedId}
  2. 加载评论列表
     ↓ GET /api/v1/content/comments/{feedId}?page=1&pageSize=20
  ↓
ContentService
  1. 查询动态详情
  2. 调用UserService.getUserInfo()获取作者信息
  3. 查询一级评论(parentId IS NULL)
  4. 对每个一级评论,查询前3条二级回复
  5. 调用UserService.getBatchUserInfo()批量获取用户信息
  6. 查询当前用户的点赞状态
  ↓
客户端显示评论列表

用户发布评论:
  1. 点击评论输入框
  2. 输入评论内容(1-500字符)
  3. 点击发送
  ↓
POST /api/v1/content/comment
  ↓
ContentService
  1. 验证用户登录状态
  2. 验证内容格式
  3. 创建评论记录
  4. 更新动态评论数(+1)
  5. 如果是二级回复,更新一级评论回复数(+1)
  6. 异步发送通知
  ↓
客户端
  1. 清空输入框
  2. 新评论插入列表顶部
  3. 评论总数+1
```

### 点赞收藏流程

```
用户点击点赞按钮(乐观更新):
  1. 立即切换UI状态(空心 ↔ 实心)
  2. 立即更新点赞数(+1或-1)
  ↓
POST /api/v1/interaction/like
{
  targetType: 'feed',
  targetId: 'feed_xxx',
  action: 'like' 或 'unlike'
}
  ↓
ContentService
  1. 验证用户登录状态
  2. 检查点赞状态
  3. action=like:
     - 未点赞: 创建点赞记录
     - 已点赞: 返回错误
  4. action=unlike:
     - 已点赞: 删除点赞记录
     - 未点赞: 返回错误
  5. 更新目标记录的点赞数(使用Redis计数器)
  ↓
客户端
  成功: 保持UI状态
  失败: 回滚UI状态,显示错误Toast
```

### 举报审核流程

```
用户点击举报:
  1. 进入举报页面
  2. 选择举报类型(harassment/pornography/fraud等)
  3. 填写描述(可选,0-200字符)
  4. 上传证据图片(可选,最多3张)
  5. 点击提交
  ↓
POST /api/v1/content/report
  ↓
ContentService → RPC调用ReportService.submitReport()
  ↓
ReportService
  1. 验证用户登录状态
  2. 验证举报对象存在
  3. 检查24小时内是否重复举报
  4. 创建举报记录
  5. 计算优先级(illegal/pornography优先级最高)
  6. 检查自动处理条件:
     - 24小时内举报≥10次: 自动下架
  7. 推送到审核队列
  8. 发送通知给管理员
  ↓
客户端
  显示"已收到您的举报,我们会尽快处理"
```

---

## 服务依赖关系

### ContentService 依赖

```
ContentService
  → UserService (RPC)
    - getUserInfo() - 获取用户信息
    - getBatchUserInfo() - 批量获取用户信息
    - getFollowingList() - 获取关注列表
  → MediaUploadService (RPC, 06-common模块)
    - uploadMedia() - 上传图片/视频
    - deleteMedia() - 删除媒体
  → LocationService (RPC, 06-common模块)
    - getNearbyLocations() - 获取附近地点
    - searchLocations() - 搜索地点
  → ReportService (RPC, 06-common模块)
    - submitReport() - 提交举报
    - checkPunishment() - 检查是否被处罚
```

### 被依赖的服务

```
ContentService 被调用:
  ← UserService (获取用户动态、点赞收藏列表)
```

---

## 数据库设计

**数据库名**: `xypai_content`

**主要表结构** (8张表):

### 1. feed (动态表)
```typescript
id, userId, type, title, content, coverImage,
locationName, locationAddress, longitude, latitude, cityId,
likeCount, commentCount, shareCount, collectCount, viewCount,
visibility, status, deleted, createdAt, updatedAt, createdTimestamp
```

**索引**:
- `(userId, deleted)`
- `(type, status, deleted)`
- `(createdTimestamp)`

### 2. comment (评论表)
```typescript
id, feedId, userId, content,
parentId, replyToUserId,
likeCount, replyCount, isTop, deleted, createdAt
```

**索引**:
- `(feedId, parentId, deleted)`
- `(userId, deleted)`

### 3. topic (话题表)
```typescript
id, name, description, coverImage,
participantCount, postCount,
isOfficial, isHot, createdAt, updatedAt
```

**索引**:
- `(name)` - unique
- `(postCount)`

### 4. feed_topic (动态话题关联表)
```typescript
id, feedId, topicName, createdAt
```

**索引**:
- `(feedId)`
- `(topicName)`

### 5. feed_media (动态媒体关联表)
```typescript
id, feedId, mediaId, mediaType, sortOrder, createdAt
```

**索引**:
- `(feedId, sortOrder)`

### 6. like (点赞表)
```typescript
id, userId, targetType, targetId, createdAt
```

**索引**:
- `(userId, targetType, targetId)` - unique
- `(targetType, targetId)`

### 7. collection (收藏表)
```typescript
id, userId, targetType, targetId, createdAt
```

**索引**:
- `(userId, targetType, targetId)` - unique
- `(userId, createdAt)`

### 8. share (分享表)
```typescript
id, userId, targetType, targetId, shareChannel, createdAt
```

**索引**:
- `(userId, createdAt)`
- `(targetType, targetId)`

---

## 技术栈

### 后端
- **框架**: Node.js + TypeScript + Express
- **ORM**: TypeORM
- **数据库**: MySQL 8.0+
- **缓存**: Redis 7.0+ (热门动态、评论列表、互动计数器)
- **消息队列**: RabbitMQ 或 Kafka (异步通知、审核任务)

### 缓存策略

#### 热门动态列表缓存
```
Key: feed:hot:page:{page}
Value: 动态列表JSON
TTL: 5分钟
更新策略: 定时刷新,发布新动态时清除
```

#### 动态详情缓存
```
Key: feed:detail:{feedId}
Value: 动态详情JSON
TTL: 10分钟
更新策略: 动态编辑/删除时清除
```

#### 评论列表缓存
```
Key: comment:list:{feedId}:page:{page}
Value: 评论列表JSON
TTL: 5分钟
更新策略: 新评论发布时清除
```

#### 互动计数器(点赞/收藏/分享/浏览)
```
Key: count:{type}:{targetId}
  例如: count:like:feed_xxx
Value: 数字
TTL: 永久
更新策略: 每分钟同步到MySQL
```

#### 热门话题缓存
```
Key: topic:hot
Value: 话题列表JSON
TTL: 1小时
更新策略: 定时刷新
```

---

## API路径规划

### Feed管理相关 (4个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/v1/content/feed/{tabType} | GET | 获取动态列表(follow/hot/local) | ✅ |
| /api/v1/content/detail/{feedId} | GET | 获取动态详情 | ✅ |
| /api/v1/content/publish | POST | 发布动态 | ✅ |
| /api/v1/content/{feedId} | DELETE | 删除动态 | ✅ |

### Comment管理相关 (3个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/v1/content/comments/{feedId} | GET | 获取评论列表 | ✅ |
| /api/v1/content/comment | POST | 发布评论 | ✅ |
| /api/v1/content/comment/{commentId} | DELETE | 删除评论 | ✅ |

### Topic管理相关 (2个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/v1/content/topics/hot | GET | 获取热门话题 | ✅ |
| /api/v1/content/topics/search | GET | 搜索话题 | ✅ |

### Interaction相关 (4个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/v1/interaction/like | POST | 点赞/取消点赞 | ✅ |
| /api/v1/interaction/collect | POST | 收藏/取消收藏 | ✅ |
| /api/v1/interaction/share | POST | 分享 | ✅ |
| /api/v1/interaction/distance/batch | POST | 批量距离计算 | ✅ |

### Moderation相关 (2个)

| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/v1/content/report | POST | 举报内容/用户 | ✅ |
| /api/v1/user/reports | GET | 查看我的举报记录 | ✅ |

**说明**:
- 所有接口都已在文档中定义
- RPC调用的接口(media upload, location)在06-common模块实现

---

## RPC接口清单

### ContentService提供 (被其他服务调用)

```typescript
/**
 * 获取用户动态列表
 * @param userId 用户ID
 * @param page 页码
 * @param pageSize 每页数量
 * @return 动态列表
 */
async getUserFeeds(params: {
  userId: string;
  page: number;
  pageSize: number;
}): Promise<FeedListResult>;

/**
 * 获取用户收藏列表
 * @param userId 用户ID
 * @param page 页码
 * @param pageSize 每页数量
 * @return 收藏列表
 */
async getUserCollections(params: {
  userId: string;
  page: number;
  pageSize: number;
}): Promise<FeedListResult>;

/**
 * 获取用户点赞列表
 * @param userId 用户ID
 * @param page 页码
 * @param pageSize 每页数量
 * @return 点赞列表
 */
async getUserLikes(params: {
  userId: string;
  page: number;
  pageSize: number;
}): Promise<FeedListResult>;
```

---

## 测试要点

### 功能测试
- [ ] 动态列表加载正常(关注/热门/同城)
- [ ] 发布动态成功(文字+图片/视频+话题+地点)
- [ ] 评论发布成功(一级+二级)
- [ ] 点赞操作正确(动态+评论)
- [ ] 收藏操作正确
- [ ] 分享功能正常
- [ ] 删除动态/评论成功
- [ ] 举报功能正常
- [ ] 话题选择正常
- [ ] 地点选择正常

### 边界测试
- [ ] 动态不存在处理
- [ ] 评论为空验证
- [ ] 内容超长验证
- [ ] 媒体数量验证
- [ ] 话题数量验证
- [ ] 重复点赞/收藏处理
- [ ] 权限验证(删除权限)
- [ ] 网络异常处理
- [ ] Token过期处理

### 性能测试
- [ ] 动态列表查询 < 100ms
- [ ] 动态详情查询 < 150ms
- [ ] 发布动态 < 300ms
- [ ] 评论发布 < 200ms
- [ ] 缓存命中率 > 80%
- [ ] 并发1000请求/秒稳定

### 安全测试
- [ ] 内容审核(敏感词)
- [ ] XSS攻击防护
- [ ] SQL注入防护
- [ ] 频率限制有效
- [ ] 权限控制正确

---

## 监控告警

### 关键指标
- 动态发布成功率
- 评论发布成功率
- 点赞操作成功率
- 推荐算法准确度
- 缓存命中率
- 平均响应时间
- 举报处理时效

### 告警规则
1. 动态发布失败率 > 1% → P2告警
2. 评论发布失败率 > 1% → P2告警
3. 点赞操作失败率 > 0.5% → P2告警
4. 缓存命中率 < 75% → P3告警
5. 响应时间 > 200ms → P2告警
6. 举报待处理数 > 100 → P2告警

---

## 完成状态

### Phase 1: 核心文档创建 ✅ 已完成
- [x] 创建 01-发现主页页面.md
- [x] 创建 02-发布动态页面.md
- [x] 创建 03-动态详情页面.md
- [x] 创建 ContentService后端服务.md (Backend)
- [x] 创建 MediaUploadService后端服务.md (06-common模块)
- [x] 创建 LocationService后端服务.md (06-common模块)
- [x] 创建 ReportService后端服务.md (06-common模块)

**文档统计**:
- 前端页面文档: 3个 ✅
- 后端服务文档: 1个(content模块) + 3个(common模块) ✅
- 总API数: 20+ 个对外API + RPC接口

### Phase 2: 功能开发 (待实施)
- [ ] 实现Feed流展示功能
- [ ] 实现动态发布功能
- [ ] 实现评论系统
- [ ] 实现互动功能(点赞/收藏/分享)
- [ ] 实现话题管理
- [ ] 实现推荐算法
- [ ] 集成RPC调用(UserService, MediaUploadService, LocationService, ReportService)

### Phase 3: 安全加固 (待实施)
- [ ] 实施内容审核(敏感词检测)
- [ ] 实施图像识别(接入第三方API)
- [ ] 实施举报审核流程
- [ ] 实施频率限制
- [ ] 完善审计日志

---

## 设计亮点

### 1. 多Tab Feed流
- 关注Tab: 个性化内容,只看关注的人
- 热门Tab: 推荐算法,基于热度分+时间衰减
- 同城Tab: 地理位置推荐,Geohash快速查询

### 2. 评论系统
- 一级评论+二级回复结构
- 支持排序(时间/热度/点赞数)
- 置顶评论优先显示
- 前3条二级回复自动展开,支持"展开更多"

### 3. 乐观更新
- 点赞/收藏立即更新UI
- 失败时自动回滚
- 提升用户体验

### 4. 推荐算法
- 热度分 = 点赞×1 + 评论×2 + 分享×3 + 收藏×2
- 时间衰减: score × Math.pow(0.5, hoursSinceCreated / 24)
- 去重: 已浏览动态不再推荐

### 5. 模块化服务
- MediaUploadService: 通用媒体上传,被所有模块复用
- LocationService: 通用位置服务,支持Geohash索引
- ReportService: 通用举报服务,统一审核流程

---

## 下一步计划

### 对接其他模块
- **UserService**: RPC接口对接(getUserInfo, getBatchUserInfo, getFollowingList)
- **MediaUploadService**: RPC接口对接(uploadMedia)
- **LocationService**: RPC接口对接(getNearbyLocations, searchLocations)
- **ReportService**: RPC接口对接(submitReport, checkPunishment)

### 功能实现
- [ ] 实现20+ 个对外API
- [ ] 实现RPC接口
- [ ] 创建8张数据库表
- [ ] 配置Redis缓存策略
- [ ] 集成消息队列(异步通知)

### 测试与上线
- [ ] 单元测试(接口测试)
- [ ] 集成测试(RPC调用)
- [ ] 性能测试(缓存命中率、响应时间、推荐算法)
- [ ] 安全测试(内容审核、XSS/SQL注入防护)
- [ ] 上线验证

---

**⚠️ 重要提示**:
ContentService是核心业务模块,直接影响用户活跃度和留存率。推荐算法需要持续优化,内容审核必须严格执行。所有RPC调用必须有超时和降级策略。

**模块维护者**: 内容域团队
**最后更新**: 2025-11-14

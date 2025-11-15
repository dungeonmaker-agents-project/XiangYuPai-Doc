# 02-user模块 (用户域)

## 模块概述

**模块职责**: 用户资料管理、社交关系管理、技能管理、用户主页展示

这是应用的**基础核心模块**，提供用户相关的所有功能，被所有其他业务模块依赖。

✅ **当前状态**: 模块已完成，文档齐全

---

## 后端服务 (1个)

### UserService (用户服务) ✅
- **文档**: [Backend/用户服务接口文档.md](./Backend/用户服务接口文档.md)
- **职责**: 用户资料管理、社交关系、技能管理、用户主页
- **端口**: 8002
- **数据库**: user_db
- **API路径**: `/api/user/*`, `/api/users/*`, `/api/skills/*`
- **接口数**: 50+ 个对外API + 3个RPC接口

**核心功能**:
- 个人主页展示（动态、收藏、点赞、资料）
- 资料编辑（11个字段实时保存）
- 查看他人主页（隐私控制）
- 社交关系（关注/粉丝、搜索、拉黑）
- 技能管理（线上/线下技能）
- 技能预约和评价

**RPC接口**:
- `createUser()` - 创建新用户（供AuthService调用）
- `getUserByPhone()` - 通过手机号查询用户（供AuthService调用）
- `getUserInfo()` - 获取用户基本信息（供所有服务调用）

---

## 前端页面 (7个) ✅

1. **[01-个人主页页面.md](./Frontend/01-个人主页页面.md)** ✅
   - 路由: `/user/profile`
   - 功能: 个人主页，包含动态、收藏、点赞、资料4个Tab
   - 主要接口:
     - `GET /api/user/profile/header` - 获取头部信息
     - `GET /api/user/profile/posts` - 获取动态列表
     - `GET /api/user/profile/favorites` - 获取收藏列表
     - `GET /api/user/profile/likes` - 获取点赞列表
     - `GET /api/user/profile/info` - 获取资料信息

2. **[02-编辑资料页面.md](./Frontend/02-编辑资料页面.md)** ✅
   - 路由: `/user/profile/edit`
   - 功能: 编辑11个资料字段，支持实时保存
   - 主要接口:
     - `GET /api/user/profile/edit` - 加载编辑数据
     - `POST /api/user/avatar/upload` - 上传头像
     - `PUT /api/user/profile/nickname` - 更新昵称
     - `PUT /api/user/profile/gender` - 更新性别
     - `PUT /api/user/profile/birthday` - 更新生日
     - `PUT /api/user/profile/residence` - 更新居住地
     - `PUT /api/user/profile/height` - 更新身高
     - `PUT /api/user/profile/weight` - 更新体重
     - `PUT /api/user/profile/occupation` - 更新职业
     - `PUT /api/user/profile/wechat` - 更新微信号
     - `PUT /api/user/profile/bio` - 更新个性签名

3. **[03-他人主页页面.md](./Frontend/03-他人主页页面.md)** ✅
   - 路由: `/users/{userId}/profile`
   - 功能: 查看他人主页，支持关注、举报、拉黑
   - 主要接口:
     - `GET /api/users/{userId}/profile` - 获取用户主页信息
     - `POST /api/users/{userId}/follow` - 关注用户
     - `DELETE /api/users/{userId}/follow` - 取消关注
     - `GET /api/users/{userId}/moments` - 获取用户动态
     - `GET /api/users/{userId}/skills` - 获取用户技能
     - `GET /api/users/{userId}/profile-detail` - 获取详细资料
     - `POST /api/users/{userId}/report` - 举报用户
     - `POST /api/users/{userId}/block` - 拉黑用户

4. **[04-粉丝列表页面.md](./Frontend/04-粉丝列表页面.md)** ✅
   - 路由: `/user/fans`
   - 功能: 查看粉丝列表，支持搜索和关注
   - 主要接口:
     - `GET /api/users/fans` - 获取粉丝列表
     - `GET /api/users/fans/search` - 搜索粉丝
     - `POST /api/users/follow` - 关注用户
     - `DELETE /api/users/follow/{targetUserId}` - 取消关注

5. **[05-关注列表页面.md](./Frontend/05-关注列表页面.md)** ✅
   - 路由: `/user/following`
   - 功能: 查看关注列表，支持搜索和取消关注
   - 主要接口:
     - `GET /api/users/following` - 获取关注列表
     - `GET /api/users/following/search` - 搜索关注列表
     - `DELETE /api/users/follow/{targetUserId}` - 取消关注

6. **[06-技能管理页面.md](./Frontend/06-技能管理页面.md)** ✅
   - 路由: `/user/skills`
   - 功能: 管理线上/线下技能，支持创建、编辑、删除、上下架
   - 主要接口:
     - `GET /api/user/skills` - 获取技能列表
     - `GET /api/skills/config` - 获取技能配置
     - `POST /api/user/skills/online` - 创建线上技能
     - `POST /api/user/skills/offline` - 创建线下技能
     - `POST /api/skills/images/upload` - 上传技能图片
     - `PUT /api/user/skills/online/{skillId}` - 更新线上技能
     - `PUT /api/user/skills/offline/{skillId}` - 更新线下技能
     - `DELETE /api/user/skills/{skillId}` - 删除技能
     - `PUT /api/user/skills/{skillId}/status` - 切换上下架

7. **[07-技能预约订单页面.md](./Frontend/07-技能预约订单页面.md)** ✅
   - 路由: `/skills/{skillId}/booking`, `/orders/confirm/{skillId}`, `/orders/{orderId}`
   - 功能: 技能预约、订单确认、支付、订单详情
   - 主要接口:
     - `GET /api/skills/{skillId}/booking-detail` - 获取技能预约详情
     - `GET /api/skills/{skillId}/reviews` - 获取评价列表
     - `GET /api/orders/confirm-info/{skillId}` - 获取订单确认信息
     - `POST /api/orders/create` - 创建订单并支付
     - `GET /api/orders/{orderId}` - 获取订单详情

---

## 核心业务流程

### 个人主页流程
```
用户进入个人主页
  ↓
GET /api/user/profile/header
  ↓
显示头部信息（头像、昵称、统计）
  ↓
默认选中"动态"Tab
  ↓
GET /api/user/profile/posts
  ↓
显示动态列表
```

### 资料编辑流程（实时保存）
```
用户进入编辑页面
  ↓
GET /api/user/profile/edit
  ↓
填充表单字段
  ↓
用户修改某个字段（如昵称）
  ↓
失去焦点触发保存
  ↓
PUT /api/user/profile/nickname
  ↓
成功：显示绿色✓
失败：显示红色✗和错误提示
```

### 关注/取消关注流程
```
用户点击关注按钮
  ↓
检查当前关注状态
  ├─ none: POST /api/users/{userId}/follow
  └─ following/mutual: DELETE /api/users/{userId}/follow
  ↓
立即更新UI（乐观更新）
  ↓
成功: 保持UI状态
失败: 恢复UI状态，显示错误
```

### 技能创建流程
```
用户进入技能管理页
  ↓
点击"发布"按钮
  ↓
选择技能类型（线上/线下）
  ↓
填写表单
  - 线上技能：游戏名称、段位、价格/局
  - 线下技能：服务类型、地点、价格/小时
  ↓
POST /api/user/skills/online 或 offline
  ↓
成功：跳转回管理页，显示新技能
失败：显示错误提示
```

### 技能预约流程
```
用户浏览技能详情
  ↓
GET /api/skills/{skillId}/booking-detail
  ↓
点击"立即预约"
  ↓
跳转到订单确认页
  ↓
填写预约信息（时间、联系方式）
  ↓
选择支付方式
  ↓
POST /api/orders/create
  ↓
余额支付：直接支付成功
第三方支付：跳转到支付页面
  ↓
跳转到订单详情页
```

---

## 服务依赖关系

### UserService 依赖

```
UserService
  → AuthService (Token验证)
  → ContentService (获取用户动态、点赞收藏)
  → OrderService (获取订单统计、评价)
```

### 被依赖的服务 (核心基础服务)

```
UserService 被调用:
  ← AuthService (创建用户、查询用户)
  ← 所有服务 (获取用户信息)
```

**⚠️ 重要**: UserService是最基础的服务，不应依赖其他业务服务，避免循环依赖。

---

## 数据库设计

**数据库名**: `user_db`

**主要表结构** (9张表):

### 1. users (用户表)
```sql
user_id, phone, country_code, nickname, avatar,
gender, birthday, residence, height, weight,
occupation, wechat, bio, is_online, status
```

### 2. user_relations (用户关注关系表)
```sql
relation_id, user_id, target_user_id, status
```

### 3. user_stats (用户统计表)
```sql
stats_id, user_id, following_count, fans_count,
posts_count, likes_count, skills_count, orders_count
```

### 4. skills (技能表)
```sql
skill_id, user_id, skill_type, skill_name, description,
cover_image, price, price_unit, rating, review_count,
-- 线上技能
game_name, game_rank, service_hours,
-- 线下技能
service_type, location_address, location_latitude, location_longitude
```

### 5. skill_images (技能图片表)
```sql
image_id, skill_id, image_url, sort_order
```

### 6. skill_promises (技能承诺表)
```sql
promise_id, skill_id, promise_content, sort_order
```

### 7. skill_available_times (技能可用时间表)
```sql
time_id, skill_id, day_of_week, start_time, end_time, enabled
```

### 8. user_blacklist (用户黑名单表)
```sql
blacklist_id, user_id, blocked_user_id
```

### 9. user_reports (用户举报表)
```sql
report_id, reporter_id, reported_user_id, reason, description, evidence, status
```

---

## 技术栈

### 后端
- **框架**: Spring Boot 3.x + Spring Cloud
- **数据库**: MySQL 8.0+
- **缓存**: Redis 7.0+ (用户信息、关注关系、技能列表缓存)
- **文件存储**: OSS (头像、技能图片)

### 缓存策略

#### 用户信息缓存
```
Key: user:info:{userId}
Value: 用户信息JSON
TTL: 10分钟
更新策略: 用户信息变更时清除
```

#### 关注关系缓存
```
Key: user:follow:{userId}:{targetUserId}
Value: 关注状态（none/following/mutual）
TTL: 10分钟
更新策略: 关注/取消关注时清除
```

#### 用户统计缓存
```
Key: user:stats:{userId}
Value: 统计信息JSON
TTL: 5分钟
更新策略: 统计变更时清除
```

#### 技能列表缓存
```
Key: skills:user:{userId}:{skillType}
Value: 技能列表JSON
TTL: 10分钟
更新策略: 技能创建/编辑/删除时清除
```

---

## API路径规划

### 个人主页相关 (5个)
| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/user/profile/header | GET | 获取头部信息 | ✅ |
| /api/user/profile/posts | GET | 获取动态列表 | ✅ |
| /api/user/profile/favorites | GET | 获取收藏列表 | ✅ |
| /api/user/profile/likes | GET | 获取点赞列表 | ✅ |
| /api/user/profile/info | GET | 获取资料信息 | ✅ |

### 资料编辑相关 (12个)
| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/user/profile/edit | GET | 加载编辑数据 | ✅ |
| /api/user/avatar/upload | POST | 上传头像 | ✅ |
| /api/user/profile/nickname | PUT | 更新昵称 | ✅ |
| /api/user/profile/gender | PUT | 更新性别 | ✅ |
| /api/user/profile/birthday | PUT | 更新生日 | ✅ |
| /api/user/profile/residence | PUT | 更新居住地 | ✅ |
| /api/user/profile/height | PUT | 更新身高 | ✅ |
| /api/user/profile/weight | PUT | 更新体重 | ✅ |
| /api/user/profile/occupation | PUT | 更新职业 | ✅ |
| /api/user/profile/wechat | PUT | 更新微信号 | ✅ |
| /api/user/profile/bio | PUT | 更新个性签名 | ✅ |

### 他人主页相关 (8个)
| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/users/{userId}/profile | GET | 获取用户主页 | ✅ |
| /api/users/{userId}/follow | POST | 关注用户 | ✅ |
| /api/users/{userId}/follow | DELETE | 取消关注 | ✅ |
| /api/users/{userId}/moments | GET | 获取动态列表 | ✅ |
| /api/users/{userId}/skills | GET | 获取技能列表 | ✅ |
| /api/users/{userId}/profile-detail | GET | 获取详细资料 | ✅ |
| /api/users/{userId}/report | POST | 举报用户 | ✅ |
| /api/users/{userId}/block | POST | 拉黑用户 | ✅ |

### 关注粉丝相关 (7个)
| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/users/fans | GET | 获取粉丝列表 | ✅ |
| /api/users/following | GET | 获取关注列表 | ✅ |
| /api/users/fans/search | GET | 搜索粉丝 | ✅ |
| /api/users/following/search | GET | 搜索关注 | ✅ |
| /api/users/follow | POST | 关注用户 | ✅ |
| /api/users/follow/{targetUserId} | DELETE | 取消关注 | ✅ |
| /api/users/{userId}/follow-stats | GET | 获取关注统计 | ✅ |

### 技能管理相关 (13个)
| API路径 | 方法 | 功能 | 状态 |
|---------|------|------|------|
| /api/user/skills | GET | 获取技能列表 | ✅ |
| /api/skills/config | GET | 获取技能配置 | ✅ |
| /api/user/skills/online | POST | 创建线上技能 | ✅ |
| /api/user/skills/offline | POST | 创建线下技能 | ✅ |
| /api/skills/images/upload | POST | 上传技能图片 | ✅ |
| /api/user/skills/{skillId} | GET | 获取技能详情 | ✅ |
| /api/user/skills/online/{skillId} | PUT | 更新线上技能 | ✅ |
| /api/user/skills/offline/{skillId} | PUT | 更新线下技能 | ✅ |
| /api/user/skills/{skillId} | DELETE | 删除技能 | ✅ |
| /api/user/skills/{skillId}/status | PUT | 切换上下架 | ✅ |
| /api/skills/available | GET | 获取可用技能 | ✅ |
| /api/skills/{skillId}/booking-detail | GET | 获取预约详情 | ✅ |
| /api/skills/{skillId}/reviews | GET | 获取评价列表 | ✅ |

**说明**: 所有接口都已在文档中定义

---

## RPC接口清单

### UserService提供 (被其他服务调用)

```java
/**
 * 创建新用户
 * @param phone 手机号
 * @param countryCode 国家区号
 * @param nickname 初始昵称
 * @return 用户ID和昵称
 */
CreateUserResponse createUser(CreateUserRequest request);

/**
 * 通过手机号查询用户
 * @param phone 手机号
 * @param countryCode 国家区号
 * @return 用户基本信息
 */
UserInfo getUserByPhone(String phone, String countryCode);

/**
 * 获取用户基本信息
 * @param userId 用户ID
 * @return 用户基本信息（userId, nickname, avatar等）
 */
UserInfo getUserInfo(Long userId);
```

---

## 测试要点

### 功能测试
- [ ] 个人主页加载正常
- [ ] 资料编辑实时保存成功
- [ ] 关注/取消关注操作正确
- [ ] 粉丝/关注列表准确
- [ ] 技能创建/编辑成功
- [ ] 技能预约流程完整
- [ ] 举报/拉黑功能正常

### 边界测试
- [ ] 空列表显示正确
- [ ] 搜索无结果处理
- [ ] 隐私权限控制
- [ ] 网络异常处理
- [ ] Token过期处理
- [ ] 并发关注防重

### 性能测试
- [ ] 用户信息查询 < 100ms
- [ ] 缓存命中率 > 85%
- [ ] 列表滚动流畅
- [ ] 图片懒加载正常

### 安全测试
- [ ] 敏感信息脱敏
- [ ] 拉黑关系隔离
- [ ] 举报记录保留
- [ ] 频率限制有效

---

## 监控告警

### 关键指标
- 用户信息查询成功率
- 缓存命中率
- 关注操作成功率
- 技能创建成功率
- 平均响应时间

### 告警规则
1. 用户查询失败率 > 0.1% → P1告警
2. 关注操作失败率 > 1% → P2告警
3. 缓存命中率 < 80% → P3告警
4. 响应时间 > 300ms → P2告警
5. 技能创建失败率 > 2% → P2告警

---

## 完成状态

### Phase 1: 核心文档创建 ✅ 已完成
- [x] 创建 01-个人主页页面.md
- [x] 创建 02-编辑资料页面.md
- [x] 创建 03-他人主页页面.md
- [x] 创建 04-粉丝列表页面.md
- [x] 创建 05-关注列表页面.md
- [x] 创建 06-技能管理页面.md
- [x] 创建 07-技能预约订单页面.md
- [x] 更新 用户服务接口文档.md (Backend)

**文档统计**:
- 前端页面文档: 7个 ✅
- 后端服务文档: 1个 ✅
- 总API数: 50+ 个对外API + 3个RPC接口

### Phase 2: 功能开发 (待实施)
- [ ] 实现个人主页功能
- [ ] 实现资料编辑功能
- [ ] 实现社交关系管理
- [ ] 实现技能管理功能
- [ ] 实现技能预约功能
- [ ] 集成ContentService（获取动态数据）
- [ ] 集成OrderService（订单相关）

### Phase 3: 安全加固 (待实施)
- [ ] 实施敏感信息加密
- [ ] 实施隐私权限控制
- [ ] 实施拉黑机制
- [ ] 实施举报审核流程
- [ ] 完善审计日志

---

## 设计亮点

### 1. 实时保存机制
- 资料编辑每个字段独立保存
- 失去焦点自动保存
- 即时反馈（✓或✗）
- 避免数据丢失

### 2. 隐私权限控制
- 可设置主页、动态、技能的查看权限
- 拉黑后双向隔离
- 举报功能完善

### 3. 技能系统
- 区分线上技能（游戏陪玩）和线下技能（生活服务）
- 支持价格、时间、地点等灵活配置
- 评价和评分系统

### 4. 社交关系管理
- 关注/粉丝/互相关注三种状态
- 支持搜索和筛选
- 乐观更新提升体验

---

## 下一步计划

### 对接其他模块
- **AuthService**: RPC接口对接（createUser, getUserByPhone）
- **ContentService**: 获取用户动态、点赞收藏数据
- **OrderService**: 获取订单统计、评价数据

### 功能实现
- [ ] 实现50+ 个对外API
- [ ] 实现3个RPC接口
- [ ] 创建9张数据库表
- [ ] 配置Redis缓存策略
- [ ] 集成OSS文件存储

### 测试与上线
- [ ] 单元测试（接口测试）
- [ ] 集成测试（RPC调用）
- [ ] 性能测试（缓存命中率、响应时间）
- [ ] 安全测试（隐私控制、数据加密）
- [ ] 上线验证

---

**⚠️ 重要提示**:
UserService是整个系统的基础服务，任何变更必须向后兼容，避免影响其他服务。RPC接口变更需要提前通知所有调用方。

**模块维护者**: 用户域团队
**最后更新**: 2025-11-14

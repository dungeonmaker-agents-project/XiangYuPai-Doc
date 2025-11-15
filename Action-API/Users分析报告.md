# Users模块接口文档分析报告

## 概述

本报告对Users模块的6个接口文档进行全面分析,识别API清单、重复接口、依赖关系、缺失功能,并提供重组建议。

**分析文档:**
1. 用户主页接口文档.md (579行, 11个API)
2. 个人资料编辑接口文档.md (652行, 12个API)
3. 技能管理接口文档.md (707行, 11个API)
4. 对方主页接口文档.md (711行, 11个API)
5. 技能预约订单接口文档.md (816行, 9个API)
6. 关注粉丝接口文档.md (573行, 7个API)

**统计:** 6个文档,共4038行,61个API接口

---

## 一、API清单(按后端Controller分类)

### 1. UserProfileController (`/api/user/profile/*`)

**用户主页接口文档.md:**
```
GET    /api/user/profile/header        获取用户主页头部信息
GET    /api/user/profile/posts         获取动态列表
GET    /api/user/profile/favorites     获取收藏列表
GET    /api/user/profile/likes         获取点赞列表
GET    /api/user/profile/info          获取资料Tab信息
```

**个人资料编辑接口文档.md:**
```
GET    /api/user/profile/edit          加载编辑页
PUT    /api/user/profile/nickname      修改昵称
PUT    /api/user/profile/gender        修改性别
PUT    /api/user/profile/bio           修改个人介绍
PUT    /api/user/profile/birthday      修改生日
PUT    /api/user/profile/residence     修改常居地
PUT    /api/user/profile/height        修改身高
PUT    /api/user/profile/weight        修改体重
PUT    /api/user/profile/occupation    修改职业
PUT    /api/user/profile/wechat        修改微信
PUT    /api/user/profile/batch         批量保存资料
```

**小计:** 16个接口

---

### 2. UserAvatarController (`/api/user/avatar/*`)

**个人资料编辑接口文档.md:**
```
POST   /api/user/avatar/upload         上传头像
```

**小计:** 1个接口

---

### 3. UserSkillsController (`/api/user/skills/*`)

**技能管理接口文档.md:**
```
GET    /api/user/skills                获取技能列表
POST   /api/user/skills/online         添加线上技能
POST   /api/user/skills/offline        添加线下技能
GET    /api/user/skills/{skillId}      获取技能详情
PUT    /api/user/skills/online/{skillId}   更新线上技能
PUT    /api/user/skills/offline/{skillId}  更新线下技能
DELETE /api/user/skills/{skillId}      删除技能
PUT    /api/user/skills/{skillId}/status   上架/下架技能
```

**小计:** 8个接口

---

### 4. SkillsController (`/api/skills/*`)

**技能管理接口文档.md:**
```
GET    /api/skills/config              获取技能配置
GET    /api/skills/available           获取可选技能列表
POST   /api/skills/images/upload       上传技能图片
```

**技能预约订单接口文档.md:**
```
GET    /api/skills/{skillId}/booking-detail    获取技能预约详情
GET    /api/skills/{skillId}/reviews           获取评价列表
```

**小计:** 5个接口

---

### 5. PostController (`/api/post/*`)

**用户主页接口文档.md:**
```
GET    /api/post/detail                获取动态详情
POST   /api/post/like                  点赞动态
POST   /api/post/favorite              收藏动态
POST   /api/post/comment               发表评论
```

**小计:** 4个接口

---

### 6. CommentController (`/api/comment/*`)

**用户主页接口文档.md:**
```
POST   /api/comment/like               点赞评论
```

**小计:** 1个接口

---

### 7. OtherUsersController (`/api/users/{userId}/*`)

**对方主页接口文档.md:**
```
GET    /api/users/{userId}/profile             获取对方主页基础信息
POST   /api/users/{userId}/follow              关注用户
DELETE /api/users/{userId}/follow              取消关注
GET    /api/users/{userId}/moments             获取对方动态列表
GET    /api/users/{userId}/skills              获取对方技能列表
GET    /api/users/{userId}/profile-detail      获取对方个人资料
POST   /api/users/{userId}/report              举报用户
POST   /api/users/{userId}/block               拉黑用户
GET    /api/users/{userId}/follow-stats        获取关注统计
```

**小计:** 9个接口

---

### 8. MomentsController (`/api/moments/{momentId}/*`)

**对方主页接口文档.md:**
```
POST   /api/moments/{momentId}/like            点赞动态
DELETE /api/moments/{momentId}/like            取消点赞
POST   /api/moments/{momentId}/unlock          解锁付费动态
```

**小计:** 3个接口

---

### 9. FollowController (`/api/users/*`)

**关注粉丝接口文档.md:**
```
GET    /api/users/fans                 获取粉丝列表
GET    /api/users/following            获取关注列表
GET    /api/users/fans/search          搜索粉丝
GET    /api/users/following/search     搜索关注列表
POST   /api/users/follow               关注用户
DELETE /api/users/follow/{targetUserId}   取消关注
```

**小计:** 6个接口

---

### 10. OrderController (`/api/orders/*`)

**技能预约订单接口文档.md:**
```
GET    /api/orders/confirm-info/{skillId}  加载订单确认信息
POST   /api/orders/create                  创建订单并支付
GET    /api/orders/{orderId}               获取订单详情
```

**小计:** 3个接口

---

### 11. UserFollowController (`/api/user/follow`)

**用户主页接口文档.md:**
```
POST   /api/user/follow                关注/取消关注
```

**小计:** 1个接口

---

## 二、❌ 严重问题:关注接口三种不同设计

### 问题描述

**关注/取消关注功能在3个文档中有3种不同的API设计:**

#### 设计1: 用户主页接口文档.md (line 291)
```typescript
POST /api/user/follow
{
  targetUserId: string | number;
  action: 'follow' | 'unfollow';
}
```
- 使用单一接口 + action参数
- 路径: /api/user/follow

#### 设计2: 对方主页接口文档.md (line 71-103)
```typescript
POST   /api/users/{userId}/follow      // 关注
DELETE /api/users/{userId}/follow      // 取消关注
```
- 使用RESTful设计 (POST/DELETE)
- 路径: /api/users/{userId}/follow
- userId在路径参数中

#### 设计3: 关注粉丝接口文档.md (line 253-291)
```typescript
POST   /api/users/follow               // 关注
{
  targetUserId: string;
}

DELETE /api/users/follow/{targetUserId}  // 取消关注
```
- 使用RESTful设计 (POST/DELETE)
- 路径: /api/users/follow/{targetUserId}
- targetUserId在路径参数中

### 影响分析

✗ **前端混乱**: 不知道该调用哪个接口
✗ **后端重复**: 可能实现了多套相同逻辑
✗ **测试困难**: 需要测试3个不同接口
✗ **文档不一致**: 造成开发团队困惑

### 推荐方案

**采用设计3 (关注粉丝接口文档的设计)**

原因:
1. ✅ RESTful规范 (POST创建关注, DELETE删除关注)
2. ✅ 路径清晰 (/api/users/follow)
3. ✅ 语义明确 (DELETE /api/users/follow/{targetUserId})
4. ✅ 符合行业标准

**统一后的接口:**
```typescript
POST   /api/users/follow               // 关注用户
{
  targetUserId: string;
}
Response: {
  followStatus: "following" | "mutual";
  followTime: string;
}

DELETE /api/users/follow/{targetUserId}  // 取消关注
Response: {
  followStatus: "none";
}
```

**需要修改的文档:**
- 用户主页接口文档.md → 删除或改为引用关注粉丝接口文档
- 对方主页接口文档.md → 改为引用关注粉丝接口文档

---

## 三、其他重复/冲突

### 1. 点赞动态接口 (可接受的重复)

**用户主页接口文档.md (line 328):**
```typescript
POST /api/post/like
{
  postId: string | number;
  action: 'like' | 'unlike';
}
```

**对方主页接口文档.md (line 198-230):**
```typescript
POST   /api/moments/{momentId}/like      // 点赞
DELETE /api/moments/{momentId}/like      // 取消点赞
```

**问题:**
- 不同的路径: /api/post vs /api/moments
- 不同的参数名: postId vs momentId
- 不同的设计: action参数 vs RESTful

**建议:** 统一为 POST/DELETE `/api/moments/{momentId}/like`

---

### 2. 技能列表接口 (正常分离)

**技能管理接口文档.md:**
```typescript
GET /api/user/skills  // 查看自己的技能
```

**对方主页接口文档.md:**
```typescript
GET /api/users/{userId}/skills  // 查看别人的技能
```

这是合理的分离,不需要合并。

---

## 四、依赖关系图

```
用户主页接口文档.md
  ├─→ 个人资料编辑接口文档.md (点击"编辑"按钮)
  ├─→ 技能管理接口文档.md (显示技能列表)
  ├─→ 关注粉丝接口文档.md (关注/粉丝数,关注按钮)
  └─→ PostController (动态、点赞、收藏、评论)

对方主页接口文档.md
  ├─→ 技能预约订单接口文档.md (查看技能 → 预约下单)
  ├─→ 关注粉丝接口文档.md (关注对方)
  └─→ 聊天模块 (私信功能,不在此模块)

技能管理接口文档.md
  ├─→ 技能预约订单接口文档.md (发布的技能可被预约)
  └─→ 通用上传接口 (上传技能图片)

技能预约订单接口文档.md
  ├─→ 订单模块 (订单管理,不在此模块)
  ├─→ 支付模块 (金币支付,不在此模块)
  └─→ 聊天模块 (联系服务提供者)

关注粉丝接口文档.md
  └─→ 用户主页 (查看用户详情)
```

---

## 五、缺失的API功能

### 高优先级缺失

1. **隐私设置管理**
   - 对方主页接口文档提到`canViewProfile`, `canViewMoments`, `canViewSkills`
   - 但没有设置这些隐私选项的API
   - 需要: `PUT /api/user/privacy`

2. **支付密码管理**
   - 技能预约订单提到金币支付
   - 但没有设置/修改支付密码的API
   - 需要: `PUT /api/user/payment-password`

3. **钱包/余额管理**
   - 订单确认接口返回`userBalance`
   - 但没有查询余额、充值、提现的API
   - 需要: `GET /api/wallet/balance`, `POST /api/wallet/recharge`

4. **退款处理**
   - 订单详情提到`canRefund`
   - 但没有申请退款的API
   - 需要: `POST /api/orders/{orderId}/refund`

5. **评价提交**
   - 技能预约订单提到`canReview`
   - 但只有查看评价的API,没有提交评价的API
   - 需要: `POST /api/skills/{skillId}/review`

6. **拉黑用户列表**
   - 对方主页有拉黑功能
   - 但没有查看拉黑列表、解除拉黑的API
   - 需要: `GET /api/user/blocked-users`, `DELETE /api/user/block/{userId}`

7. **举报历史**
   - 对方主页有举报功能
   - 但没有查看举报历史的API
   - 需要: `GET /api/user/reports`

### 中优先级缺失

8. **账号注销**
   - 应该有注销账号的功能
   - 需要: `DELETE /api/user/account`

9. **密码修改**
   - 登录密码修改
   - 需要: `PUT /api/user/password`

10. **实名认证**
    - 多处提到`isRealNameVerified`
    - 但没有实名认证的API
    - 需要: `POST /api/user/verify-identity`

11. **消息通知设置**
    - 应该有推送通知开关设置
    - 需要: `PUT /api/user/notification-settings`

12. **技能分类管理**
    - 技能管理提到分类,但没有获取分类列表的API
    - 需要: `GET /api/skills/categories`

### 低优先级缺失

13. **动态草稿箱**
    - 发布动态时可能需要草稿功能
    - 需要: `GET /api/post/drafts`, `POST /api/post/drafts`

14. **评论回复**
    - 用户主页有评论功能,但没有回复评论的API
    - 需要: `POST /api/comment/reply`

15. **删除动态**
    - 应该可以删除自己的动态
    - 需要: `DELETE /api/post/{postId}`

---

## 六、前后端文档重组方案

### 当前问题

1. 文档按功能模块组织,但不区分前端视角和后端视角
2. 一个页面可能需要查看多个文档才能找到所有接口
3. 一个微服务可能分散在多个文档中

### 重组目标

**参考Home模块重组方案:**
- **Frontend/** - 按页面组织,供前端开发使用
- **Backend/** - 按微服务组织,供后端开发使用

---

### Frontend/ (前端视图 - 按页面组织)

```
Frontend/
└── Users/
    ├── 01-我的主页页面.md
    │   ├── 页面概述: 用户查看自己的主页
    │   ├── 接口列表:
    │   │   - GET /api/user/profile/header
    │   │   - GET /api/user/profile/posts
    │   │   - GET /api/user/profile/favorites
    │   │   - GET /api/user/profile/likes
    │   │   - GET /api/user/profile/info
    │   │   - POST /api/post/like
    │   │   - POST /api/post/favorite
    │   └── 使用后端服务: UserProfileService, PostService
    │
    ├── 02-个人资料编辑页面.md
    │   ├── 页面概述: 编辑个人资料
    │   ├── 接口列表:
    │   │   - GET /api/user/profile/edit
    │   │   - POST /api/user/avatar/upload
    │   │   - PUT /api/user/profile/* (11个字段更新接口)
    │   └── 使用后端服务: UserProfileService, UploadService
    │
    ├── 03-技能管理页面.md
    │   ├── 页面概述: 管理自己的技能
    │   ├── 接口列表:
    │   │   - GET /api/user/skills
    │   │   - POST /api/user/skills/online
    │   │   - POST /api/user/skills/offline
    │   │   - PUT /api/user/skills/*/{skillId}
    │   │   - DELETE /api/user/skills/{skillId}
    │   └── 使用后端服务: SkillService, UploadService
    │
    ├── 04-对方主页页面.md
    │   ├── 页面概述: 查看其他用户的主页
    │   ├── 接口列表:
    │   │   - GET /api/users/{userId}/profile
    │   │   - POST /api/users/{userId}/follow
    │   │   - DELETE /api/users/{userId}/follow
    │   │   - GET /api/users/{userId}/moments
    │   │   - POST /api/moments/{momentId}/like
    │   │   - POST /api/moments/{momentId}/unlock
    │   └── 使用后端服务: UserService, MomentService, FollowService
    │
    ├── 05-技能详情页面.md
    │   ├── 页面概述: 查看技能详情并预约
    │   ├── 接口列表:
    │   │   - GET /api/skills/{skillId}/booking-detail
    │   │   - GET /api/skills/{skillId}/reviews
    │   └── 使用后端服务: SkillService
    │
    ├── 06-订单确认页面.md
    │   ├── 页面概述: 确认预约并支付
    │   ├── 接口列表:
    │   │   - GET /api/orders/confirm-info/{skillId}
    │   │   - POST /api/orders/create
    │   └── 使用后端服务: OrderService, PaymentService
    │
    ├── 07-订单详情页面.md
    │   ├── 页面概述: 查看订单详情
    │   ├── 接口列表:
    │   │   - GET /api/orders/{orderId}
    │   └── 使用后端服务: OrderService
    │
    ├── 08-关注列表页面.md
    │   ├── 页面概述: 查看关注的人
    │   ├── 接口列表:
    │   │   - GET /api/users/following
    │   │   - GET /api/users/following/search
    │   │   - DELETE /api/users/follow/{targetUserId}
    │   └── 使用后端服务: FollowService
    │
    ├── 09-粉丝列表页面.md
    │   ├── 页面概述: 查看粉丝
    │   ├── 接口列表:
    │   │   - GET /api/users/fans
    │   │   - GET /api/users/fans/search
    │   │   - POST /api/users/follow
    │   └── 使用后端服务: FollowService
    │
    └── 10-动态详情页面.md
        ├── 页面概述: 查看动态详情和评论
        ├── 接口列表:
        │   - GET /api/post/detail
        │   - POST /api/post/like
        │   - POST /api/post/comment
        │   - POST /api/comment/like
        └── 使用后端服务: PostService, CommentService
```

---

### Backend/ (后端视图 - 按微服务组织)

```
Backend/
├── UserService/ (用户服务)
│   ├── 用户服务接口文档.md
│   ├── 服务职责:
│   │   - 用户资料管理
│   │   - 头像上传
│   │   - 隐私设置
│   │   - 账号管理
│   ├── 接口清单:
│   │   ├── 资料相关 (16个API)
│   │   │   - GET  /api/user/profile/header
│   │   │   - GET  /api/user/profile/posts
│   │   │   - GET  /api/user/profile/favorites
│   │   │   - GET  /api/user/profile/likes
│   │   │   - GET  /api/user/profile/info
│   │   │   - GET  /api/user/profile/edit
│   │   │   - PUT  /api/user/profile/nickname
│   │   │   - PUT  /api/user/profile/gender
│   │   │   - PUT  /api/user/profile/bio
│   │   │   - PUT  /api/user/profile/birthday
│   │   │   - PUT  /api/user/profile/residence
│   │   │   - PUT  /api/user/profile/height
│   │   │   - PUT  /api/user/profile/weight
│   │   │   - PUT  /api/user/profile/occupation
│   │   │   - PUT  /api/user/profile/wechat
│   │   │   - PUT  /api/user/profile/batch
│   │   ├── 头像相关 (1个API)
│   │   │   - POST /api/user/avatar/upload
│   │   ├── 他人主页 (9个API)
│   │   │   - GET  /api/users/{userId}/profile
│   │   │   - GET  /api/users/{userId}/moments
│   │   │   - GET  /api/users/{userId}/skills
│   │   │   - GET  /api/users/{userId}/profile-detail
│   │   │   - POST /api/users/{userId}/report
│   │   │   - POST /api/users/{userId}/block
│   │   │   - GET  /api/users/{userId}/follow-stats
│   │   │   - POST /api/users/{userId}/follow (待统一)
│   │   │   - DELETE /api/users/{userId}/follow (待统一)
│   │   └── 需新增 (7个API)
│   │       - GET  /api/user/privacy                    # 获取隐私设置
│   │       - PUT  /api/user/privacy                    # 更新隐私设置
│   │       - GET  /api/user/blocked-users              # 拉黑列表
│   │       - DELETE /api/user/block/{userId}           # 解除拉黑
│   │       - PUT  /api/user/password                   # 修改密码
│   │       - POST /api/user/verify-identity            # 实名认证
│   │       - DELETE /api/user/account                  # 注销账号
│   └── 依赖服务:
│       - FollowService (关注关系)
│       - UploadService (头像上传)
│       - NotificationService (通知)
│
├── SkillService/ (技能服务)
│   ├── 技能服务接口文档.md
│   ├── 服务职责:
│   │   - 技能管理 (CRUD)
│   │   - 技能预约信息
│   │   - 技能评价
│   ├── 接口清单:
│   │   ├── 技能管理 (8个API)
│   │   │   - GET    /api/user/skills
│   │   │   - POST   /api/user/skills/online
│   │   │   - POST   /api/user/skills/offline
│   │   │   - GET    /api/user/skills/{skillId}
│   │   │   - PUT    /api/user/skills/online/{skillId}
│   │   │   - PUT    /api/user/skills/offline/{skillId}
│   │   │   - DELETE /api/user/skills/{skillId}
│   │   │   - PUT    /api/user/skills/{skillId}/status
│   │   ├── 技能配置 (3个API)
│   │   │   - GET  /api/skills/config
│   │   │   - GET  /api/skills/available
│   │   │   - POST /api/skills/images/upload
│   │   ├── 技能预约 (2个API)
│   │   │   - GET  /api/skills/{skillId}/booking-detail
│   │   │   - GET  /api/skills/{skillId}/reviews
│   │   └── 需新增 (2个API)
│   │       - POST /api/skills/{skillId}/review         # 提交评价
│   │       - GET  /api/skills/categories               # 技能分类
│   └── 依赖服务:
│       - OrderService (订单信息)
│       - UploadService (技能图片)
│
├── OrderService/ (订单服务)
│   ├── 订单服务接口文档.md
│   ├── 服务职责:
│   │   - 订单创建
│   │   - 订单查询
│   │   - 退款处理
│   ├── 接口清单:
│   │   ├── 订单管理 (3个API)
│   │   │   - GET  /api/orders/confirm-info/{skillId}
│   │   │   - POST /api/orders/create
│   │   │   - GET  /api/orders/{orderId}
│   │   └── 需新增 (2个API)
│   │       - POST /api/orders/{orderId}/refund        # 申请退款
│   │       - POST /api/orders/{orderId}/cancel        # 取消订单
│   └── 依赖服务:
│       - SkillService (技能信息)
│       - PaymentService (支付)
│       - UserService (用户信息)
│
├── FollowService/ (关注服务)
│   ├── 关注服务接口文档.md
│   ├── 服务职责:
│   │   - 关注/取关
│   │   - 粉丝/关注列表
│   │   - 关注统计
│   ├── 接口清单:
│   │   ├── 关注管理 (2个API) ⚠️ 需统一
│   │   │   - POST   /api/users/follow
│   │   │   - DELETE /api/users/follow/{targetUserId}
│   │   ├── 列表查询 (4个API)
│   │   │   - GET /api/users/fans
│   │   │   - GET /api/users/following
│   │   │   - GET /api/users/fans/search
│   │   │   - GET /api/users/following/search
│   │   └── 统计 (1个API)
│   │       - GET /api/users/{userId}/follow-stats
│   └── 依赖服务:
│       - UserService (用户信息)
│
├── PostService/ (动态服务)
│   ├── 动态服务接口文档.md
│   ├── 服务职责:
│   │   - 动态发布/删除
│   │   - 动态点赞/收藏
│   │   - 动态详情
│   ├── 接口清单:
│   │   ├── 动态管理 (3个API)
│   │   │   - GET  /api/post/detail
│   │   │   - POST /api/post/like
│   │   │   - POST /api/post/favorite
│   │   └── 需新增 (2个API)
│   │       - DELETE /api/post/{postId}                # 删除动态
│   │       - GET    /api/post/drafts                  # 草稿箱
│   └── 依赖服务:
│       - UserService (用户信息)
│       - CommentService (评论)
│
├── CommentService/ (评论服务)
│   ├── 评论服务接口文档.md
│   ├── 服务职责:
│   │   - 评论发布
│   │   - 评论点赞
│   │   - 评论回复
│   ├── 接口清单:
│   │   ├── 评论管理 (2个API)
│   │   │   - POST /api/post/comment
│   │   │   - POST /api/comment/like
│   │   └── 需新增 (1个API)
│   │       - POST /api/comment/reply                  # 回复评论
│   └── 依赖服务:
│       - PostService (动态信息)
│       - UserService (用户信息)
│
├── MomentService/ (动态服务 - 对方主页视角)
│   ├── 动态服务接口文档.md
│   ├── 服务职责:
│   │   - 查看他人动态
│   │   - 付费内容解锁
│   │   - 动态点赞
│   ├── 接口清单:
│   │   - POST   /api/moments/{momentId}/like
│   │   - DELETE /api/moments/{momentId}/like
│   │   - POST   /api/moments/{momentId}/unlock
│   └── 依赖服务:
│       - PaymentService (解锁付费)
│       - UserService (用户信息)
│
└── PaymentService/ (支付服务 - 可被远程调用)
    ├── 支付服务接口文档.md
    ├── 服务职责:
    │   - 金币支付
    │   - 余额查询
    │   - 充值/提现
    │   - 支付密码
    ├── 接口清单: (需新增)
    │   - GET  /api/wallet/balance                     # 查询余额
    │   - POST /api/wallet/recharge                    # 充值
    │   - POST /api/wallet/withdraw                    # 提现
    │   - PUT  /api/user/payment-password              # 设置支付密码
    │   - POST /api/payment/verify-password            # 验证支付密码
    └── 依赖服务:
        - OrderService (订单信息)
        - UserService (用户信息)
```

---

## 七、接口统一规范建议

### 1. 关注接口统一(最高优先级)

**当前冲突:**
- `/api/user/follow` (action参数)
- `/api/users/{userId}/follow` (RESTful)
- `/api/users/follow` (RESTful)

**统一方案:**
```typescript
POST   /api/users/follow
{
  targetUserId: string;
}
Response: {
  code: 200,
  message: "关注成功",
  data: {
    followStatus: "following" | "mutual";
    followTime: string;
  }
}

DELETE /api/users/follow/{targetUserId}
Response: {
  code: 200,
  message: "已取消关注",
  data: {
    followStatus: "none";
  }
}
```

**修改文档:**
- 用户主页接口文档.md → 删除"关注/取消关注"章节,添加引用
- 对方主页接口文档.md → 修改接口路径为统一方案
- 关注粉丝接口文档.md → 保持不变(作为标准)

---

### 2. 点赞接口统一

**当前冲突:**
- `/api/post/like` (action参数)
- `/api/moments/{momentId}/like` (RESTful)

**统一方案:**
```typescript
POST   /api/moments/{momentId}/like
DELETE /api/moments/{momentId}/like
```

**理由:**
- 统一命名为"moments"(动态)
- RESTful设计更清晰
- 便于扩展(如点赞统计)

---

### 3. 技能接口路径规范

**当前状态:**
- `/api/user/skills` - 查看自己的技能
- `/api/users/{userId}/skills` - 查看他人的技能
- `/api/skills/*` - 技能配置和预约

**建议:** 保持现状,这是合理的分离

---

## 八、数据模型优化建议

### 1. 用户资料表 (users)

**建议字段:**
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  nickname VARCHAR(50),
  avatar VARCHAR(255),
  gender ENUM('male', 'female'),
  birthday DATE,
  age INT GENERATED ALWAYS AS (YEAR(CURDATE()) - YEAR(birthday)),
  bio VARCHAR(200),
  residence VARCHAR(100),
  height INT,  -- cm
  weight INT,  -- kg
  occupation VARCHAR(100),
  wechat VARCHAR(50),
  wechat_unlock_password VARCHAR(255),

  -- 统计字段 (考虑迁移到 user_stats 表)
  following_count INT DEFAULT 0,
  fans_count INT DEFAULT 0,

  -- 隐私设置 (考虑迁移到 user_privacy 表)
  can_view_profile BOOLEAN DEFAULT TRUE,
  can_view_moments BOOLEAN DEFAULT TRUE,
  can_view_skills BOOLEAN DEFAULT TRUE,
  show_occupation BOOLEAN DEFAULT TRUE,
  show_birthday BOOLEAN DEFAULT TRUE,

  -- 认证状态
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**建议拆分:**

#### user_stats (用户统计表)
```sql
CREATE TABLE user_stats (
  user_id BIGINT PRIMARY KEY,
  following_count INT DEFAULT 0,
  fans_count INT DEFAULT 0,
  posts_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  favorites_count INT DEFAULT 0,
  updated_at TIMESTAMP
);
```

#### user_privacy (隐私设置表)
```sql
CREATE TABLE user_privacy (
  user_id BIGINT PRIMARY KEY,
  can_view_profile BOOLEAN DEFAULT TRUE,
  can_view_moments BOOLEAN DEFAULT TRUE,
  can_view_skills BOOLEAN DEFAULT TRUE,
  show_occupation BOOLEAN DEFAULT TRUE,
  show_birthday BOOLEAN DEFAULT TRUE,
  show_location BOOLEAN DEFAULT TRUE,
  allow_message BOOLEAN DEFAULT TRUE,
  updated_at TIMESTAMP
);
```

---

### 2. 技能表 (skills)

```sql
CREATE TABLE skills (
  id BIGINT PRIMARY KEY,
  user_id BIGINT NOT NULL,
  skill_type ENUM('online', 'offline'),
  skill_name VARCHAR(100),
  skill_icon VARCHAR(255),
  title VARCHAR(100),
  description TEXT,
  images JSON,  -- 存储图片URL数组

  -- 线上技能字段
  rank VARCHAR(50),
  price_per_game INT,

  -- 线下技能字段
  available_time TIMESTAMP,
  location VARCHAR(100),
  price_per_hour INT,

  is_online BOOLEAN DEFAULT TRUE,  -- 上架状态
  rating DECIMAL(3,2),
  order_count INT DEFAULT 0,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_user_id (user_id),
  INDEX idx_skill_type (skill_type),
  INDEX idx_skill_name (skill_name)
);
```

---

### 3. 关注关系表 (user_follows)

```sql
CREATE TABLE user_follows (
  id BIGINT PRIMARY KEY,
  follower_id BIGINT NOT NULL,      -- 关注者ID
  following_id BIGINT NOT NULL,     -- 被关注者ID
  follow_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uk_follow (follower_id, following_id),
  INDEX idx_follower (follower_id),
  INDEX idx_following (following_id)
);
```

**查询优化:**
```sql
-- 查询A的粉丝
SELECT follower_id FROM user_follows WHERE following_id = A;

-- 查询A关注的人
SELECT following_id FROM user_follows WHERE follower_id = A;

-- 查询互相关注 (A和B)
SELECT COUNT(*) FROM user_follows
WHERE (follower_id = A AND following_id = B)
   OR (follower_id = B AND following_id = A);
```

---

### 4. 订单表 (skill_orders)

```sql
CREATE TABLE skill_orders (
  id BIGINT PRIMARY KEY,
  order_no VARCHAR(32) UNIQUE,
  skill_id BIGINT NOT NULL,
  buyer_id BIGINT NOT NULL,
  seller_id BIGINT NOT NULL,
  sessions INT NOT NULL,
  unit_price INT NOT NULL,
  total_amount INT NOT NULL,
  booking_time TIMESTAMP NOT NULL,
  status ENUM('paid', 'in_progress', 'completed', 'cancelled', 'refunded'),

  paid_at TIMESTAMP,
  completed_at TIMESTAMP,
  cancelled_at TIMESTAMP,
  refunded_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_buyer (buyer_id),
  INDEX idx_seller (seller_id),
  INDEX idx_skill (skill_id),
  INDEX idx_status (status)
);
```

---

## 九、性能优化建议

### 1. Redis缓存策略

```typescript
// 用户资料缓存 (30分钟)
cache:user:profile:{userId}  → TTL: 1800s

// 关注/粉丝数缓存 (5分钟)
cache:user:stats:{userId}  → TTL: 300s

// 技能列表缓存 (10分钟)
cache:user:skills:{userId}  → TTL: 600s

// 关注状态缓存 (永久,手动清除)
cache:follow:{followerId}:{followingId}  → TTL: -1

// 粉丝列表缓存 (5分钟)
cache:user:fans:{userId}:{page}  → TTL: 300s
```

### 2. 数据库查询优化

**关注列表分页查询:**
```sql
-- 不推荐 (两次查询)
SELECT COUNT(*) FROM user_follows WHERE follower_id = ?;
SELECT * FROM user_follows WHERE follower_id = ? LIMIT ?, ?;

-- 推荐 (使用FOUND_ROWS)
SELECT SQL_CALC_FOUND_ROWS * FROM user_follows
WHERE follower_id = ?
LIMIT ?, ?;
SELECT FOUND_ROWS();
```

**技能列表查询优化:**
```sql
-- 添加覆盖索引
CREATE INDEX idx_user_skills ON skills(user_id, is_online, created_at);

-- 查询
SELECT * FROM skills
WHERE user_id = ? AND is_online = TRUE
ORDER BY created_at DESC
LIMIT ?, ?;
```

---

## 十、安全性建议

### 1. 敏感信息脱敏

**个人资料:**
- 微信号: 仅好友可见完整,非好友显示 "wx****"
- 生日: 根据隐私设置,可能隐藏为 "******"
- 职业: 根据隐私设置,可能隐藏为 "******"

**实现:**
```typescript
// 后端VO
class UserProfileVO {
  wechat: string;  // 根据关系脱敏

  @JsonIgnore
  private wechatRaw: string;

  getWechat(viewerId: string): string {
    if (this.isFriend(viewerId)) {
      return this.wechatRaw;
    }
    if (this.wechatRaw) {
      return "wx****";
    }
    return "";
  }
}
```

---

### 2. 权限验证

**接口级权限:**
```typescript
// 修改资料 - 只能修改自己的
@RequiresPermissions("user:profile:edit:self")
PUT /api/user/profile/nickname

// 查看他人资料 - 根据隐私设置
@RequiresPermissions("user:profile:view:others")
GET /api/users/{userId}/profile

// 拉黑用户 - 只能拉黑别人,不能拉黑自己
@PreAuthorize("@ss.hasPermi('user:block') and #userId != authentication.userId")
POST /api/users/{userId}/block
```

---

### 3. 防刷机制

**关注/取关:**
- 同一用户对同一目标: 1分钟内最多操作3次
- 同一用户: 1小时内最多关注50人
- Redis限流: `rate_limit:follow:{userId}` → INCR + EXPIRE

**搜索:**
- 同一用户: 10秒内最多搜索5次
- 防抖: 前端500ms,后端限流1秒

**订单创建:**
- 同一用户: 1分钟内最多创建1个订单(同一技能)
- 幂等性: `order:idempotent:{userId}:{skillId}` → SETNX

---

## 十一、优先级修复清单

### 🔴 P0 - 紧急 (必须立即修复)

1. **统一关注接口** - 三套不同API造成严重混乱
   - 修改文档: 用户主页、对方主页、关注粉丝
   - 统一为: POST/DELETE `/api/users/follow`
   - 预计工作量: 1天

2. **统一点赞接口** - 动态点赞有两套API
   - 统一为: POST/DELETE `/api/moments/{momentId}/like`
   - 预计工作量: 0.5天

### 🟡 P1 - 高优先级 (本周完成)

3. **新增缺失的支付相关API** (5个)
   - GET /api/wallet/balance
   - POST /api/wallet/recharge
   - PUT /api/user/payment-password
   - POST /api/payment/verify-password
   - POST /api/orders/{orderId}/refund
   - 预计工作量: 3天

4. **新增隐私设置API** (2个)
   - GET /api/user/privacy
   - PUT /api/user/privacy
   - 预计工作量: 1天

5. **新增拉黑管理API** (2个)
   - GET /api/user/blocked-users
   - DELETE /api/user/block/{userId}
   - 预计工作量: 1天

6. **新增评价提交API** (1个)
   - POST /api/skills/{skillId}/review
   - 预计工作量: 1天

### 🟢 P2 - 中优先级 (两周内完成)

7. **重组文档结构**
   - 创建 Frontend/ 和 Backend/ 文件夹
   - 拆分为10个前端文档 + 8个后端文档
   - 预计工作量: 2天

8. **新增账号管理API** (3个)
   - PUT /api/user/password
   - POST /api/user/verify-identity
   - DELETE /api/user/account
   - 预计工作量: 2天

9. **新增评论回复API** (1个)
   - POST /api/comment/reply
   - 预计工作量: 0.5天

10. **数据库优化**
    - 拆分 user_stats 表
    - 拆分 user_privacy 表
    - 优化索引
    - 预计工作量: 1天

### 🔵 P3 - 低优先级 (有时间再做)

11. **新增动态草稿功能** (2个API)
12. **新增技能分类管理** (1个API)
13. **新增删除动态功能** (1个API)

---

## 十二、文档质量评分

### 综合评分: ⭐⭐⭐⭐ (4/5星)

**优点:**
✅ 文档结构完整,包含操作流程、接口定义、验证规则、异常处理
✅ TypeScript类型定义清晰
✅ 前端验证和行为说明详细
✅ 异常处理覆盖全面
✅ 数据格式规范明确

**缺点:**
❌ 同一功能有多套API设计(关注、点赞)
❌ 缺少前后端视角分离
❌ 部分核心功能缺失API(支付、隐私、拉黑)
❌ 没有性能指标要求
❌ 缺少监控和日志规范

**改进建议:**
1. 立即修复关注接口冲突
2. 补充缺失的支付/隐私API
3. 重组为Frontend/Backend双视角文档
4. 添加性能SLA要求
5. 添加监控埋点说明

---

## 十三、总结

### 文档统计

| 文档名称 | 行数 | 接口数 | 主要功能 |
|---------|------|-------|---------|
| 用户主页接口文档.md | 579 | 11 | 查看自己的主页,动态,收藏,点赞 |
| 个人资料编辑接口文档.md | 652 | 12 | 编辑个人资料 |
| 技能管理接口文档.md | 707 | 11 | 管理技能 |
| 对方主页接口文档.md | 711 | 11 | 查看他人主页 |
| 技能预约订单接口文档.md | 816 | 9 | 预约技能,订单管理 |
| 关注粉丝接口文档.md | 573 | 7 | 关注/粉丝管理 |
| **总计** | **4038** | **61** | - |

### 核心问题

1. **关注接口三套设计** - 最严重,必须立即统一
2. **点赞接口两套设计** - 需要统一
3. **缺少支付相关API** - 影响订单功能
4. **缺少隐私设置API** - 影响用户体验
5. **文档组织不利于开发** - 需要重组

### 下一步行动

**Week 1 (紧急):**
- [ ] 统一关注接口设计
- [ ] 统一点赞接口设计
- [ ] 更新相关文档

**Week 2 (高优先级):**
- [ ] 新增支付相关API (5个)
- [ ] 新增隐私设置API (2个)
- [ ] 新增拉黑管理API (2个)
- [ ] 新增评价提交API (1个)

**Week 3-4 (中优先级):**
- [ ] 重组文档结构 (Frontend + Backend)
- [ ] 新增账号管理API (3个)
- [ ] 数据库优化
- [ ] 性能测试和优化

---

**报告生成时间:** 2025-11-13
**分析人:** Claude
**建议审阅:** 技术负责人、前端Leader、后端Leader
